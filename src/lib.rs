use std::collections::{hash_map::Entry::Vacant, HashMap};

// try_quick executes f on values slice and subslices when an error is returned
// until maxdepth amounts of slicing happened.
// It returns the indices of values that kept returning errors.
pub fn try_quick<T, E, F>(values: &[T], maxdepth: u8, mut f: F) -> Result<HashMap<usize, String>, E>
where
    T: Clone + std::fmt::Debug,
    E: std::fmt::Display,
    F: FnMut(&[T]) -> Result<(), E>,
{
    assert!(!values.is_empty());

    match f(values) {
        Ok(()) => return Ok([].into()),
        Err(e) if maxdepth == 0 => return Err(e),
        Err(_) => {}
    };

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
