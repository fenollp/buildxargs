use std::collections::HashMap;
use std::fmt::Display;

// try_quick executes f on values slice and subslices when an error is returned
// until maxdepth amounts of slicing happened.
// It returns the indices of values that kept returning errors.
pub fn try_quick<T, E, F>(values: &[T], maxdepth: u8, mut f: F) -> Result<HashMap<usize, String>, E>
where
    T: Clone + std::fmt::Debug,
    E: Display, //Clone, //+ std::error::Error, TODO: decide
    F: FnMut(&[T]) -> Result<(), E>,
{
    assert!(!values.is_empty());
    assert!(maxdepth > 0);

    if let Ok(()) = f(values) {
        return Ok(HashMap::new());
    }

    let mut xs: Vec<T> = Vec::with_capacity(values.len());
    let mut ixs: Vec<usize> = (0..values.len()).collect();
    let mut passed: Vec<usize> = Vec::with_capacity(values.len());
    let mut failed: HashMap<usize, String> = HashMap::with_capacity(values.len());
    for _ in 1..=maxdepth {
        let ixsn = ixs.len();
        if ixsn == 0 {
            return Ok(HashMap::new());
        }
        if ixsn / 2 == 0 {
            break;
        }
        for indices in ixs.chunks(ixsn / 2) {
            xs.clear();
            for i in indices {
                xs.push(values[*i].clone());
            }

            match f(&xs) {
                Ok(()) => passed.extend(indices.iter()),
                Err(e) => {
                    for &ix in indices {
                        if !failed.contains_key(&ix) {
                            //let _ = failed.insert(ix, e.clone());
                            let _ = failed.insert(ix, format!("{e}"));
                        }
                    }
                }
            }
        }
        for &index in &passed {
            let _ = failed.remove(&index);
            if let Some(ix) = ixs.iter().position(|&ix| ix == index) {
                let _ = ixs.swap_remove(ix);
            }
        }
    }

    Ok(failed)
}

#[test]
fn test_bad_job_zero() {
    let xs = (0..9).collect::<Vec<_>>();

    let err = format!("{}", "NaN".parse::<u32>().unwrap_err());

    use std::ops::RangeInclusive as RI;
    let errors = |range: RI<usize>| range.map(|v| (v, err.clone())).collect::<HashMap<_, _>>();

    for (d, errors) in [
        (1, errors(0..=3)),
        (2, errors(0..=1)),
        (3, errors(0..=0)),
        (4, errors(0..=0)),
        (5, errors(0..=0)),
        (6, errors(0..=0)),
    ] {
        let ixs_failed = try_quick(&xs, d, |subxs| {
            if !subxs.contains(&0) {
                Ok(())
            } else {
                Err(err.clone())
            }
        });
        assert_eq!((d, ixs_failed), (d, Ok(errors)));
    }
}

#[test]
fn test_transient_job_error() {
    use std::ops::Range;
    let xs = |range: Range<usize>| range.collect::<Vec<_>>();

    let err = format!("{}", "NaN".parse::<u32>().unwrap_err());

    use rand::Rng;
    let mut rng = rand::thread_rng();

    for (d, xs, is_ok) in [
        // (1, xs(0..9), false),
        // (2, xs(0..9), false),
        // (3, xs(0..9), true),
        // (4, xs(0..9), true),
        // (5, xs(0..9), true),
        (1, xs(0..999), false),
        //      (2, xs(0..999), false),
        //    (3, xs(0..999), false),
        //(4, xs(0..999), false),
        //  (5, xs(0..999), false),
    ] {
        let ixs_failed = try_quick(&xs, d, |_subxs| {
            if rng.gen::<bool>() {
                Ok(())
            } else {
                Err(err.clone())
            }
        });
        assert_eq!((d, ixs_failed.is_ok()), (d, true));
        //        if is_ok {
        //        assert_eq!((d, ixs_failed.ok()), (d, Some(HashMap::new())));
        //      } else {
        //     assert_eq!((d, ixs_failed.is_err()), (d, true));
        assert!(dbg!((d, ixs_failed.unwrap().len())) > (d, 0));
        //}
    }
}
