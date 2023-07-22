use std::collections::HashMap;

use buildxargs::try_quick;

#[test]
fn test_bad_job_zero() {
    let xs = (0..=99).collect::<Vec<_>>();

    let err = format!("{}", "NaN".parse::<u32>().unwrap_err());

    let ixs_failed =
        try_quick(&xs, 0, |subxs| if !subxs.contains(&0) { Ok(()) } else { Err(err.clone()) });
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
        let ixs_failed =
            try_quick(&xs, d, |subxs| if !subxs.contains(&0) { Ok(()) } else { Err(err.clone()) });
        assert_eq!((d, ixs_failed), (d, Ok(errors)));
    }
}
