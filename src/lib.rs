use std::collections::hash_map::Entry::Vacant;
use std::collections::HashMap;
use std::fmt::Display;

// try_quick executes f on values slice and subslices when an error is returned
// until maxdepth amounts of slicing happened.
// It returns the indices of values that kept returning errors.
pub fn try_quick<T, E, F>(values: &[T], maxdepth: u8, mut f: F) -> Result<HashMap<usize, String>, E>
where
    T: Clone + std::fmt::Debug,
    E: Display,
    F: FnMut(&[T]) -> Result<(), E>,
{
    assert!(!values.is_empty());

    let initial_attempt = f(values);
    if let Ok(()) = initial_attempt {
        return Ok(HashMap::new());
    }
    if maxdepth == 0 {
        initial_attempt?;
        unreachable!();
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
                        if let Vacant(entry) = failed.entry(ix) {
                            let _ = entry.insert(format!("{e}")); // TODO: e.clone()
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
    let xs = (0..=99).collect::<Vec<_>>();

    let err = format!("{}", "NaN".parse::<u32>().unwrap_err());

    let ixs_failed = try_quick(&xs, 0, |subxs| {
        if !subxs.contains(&0) {
            Ok(())
        } else {
            Err(err.clone())
        }
    });
    assert_eq!(ixs_failed, Err(err.clone()));

    use std::ops::RangeInclusive as RI;
    let errors = |range: RI<usize>| range.map(|v| (v, err.clone())).collect::<HashMap<_, _>>();

    for (d, errors) in [
        (1, errors(0..=49)),
        (2, errors(0..=24)),
        (3, errors(0..=11)),
        (4, errors(0..=5)),
        (5, errors(0..=2)),
        (6, errors(0..=0)),
        (7, errors(0..=0)),
        (8, errors(0..=0)),
        (9, errors(0..=0)),
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
