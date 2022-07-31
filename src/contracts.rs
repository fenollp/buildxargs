use assert_no_alloc::assert_no_alloc;
use no_panic::no_panic;

// no_panic

// Our business logic says there's no way this panics,
// so let's ensure/enforce/document it!

// cf https://github.com/dtolnay/no-panic/issues/8 for inlining
// Also, push for proc-macro on expressions!

#[inline(never)]
#[no_panic]
fn f(x: u32) -> Option<u32> {
    Some(x)
}

#[inline(never)]
#[no_panic]
#[test]
fn do_not_panic_with_unwrap() {
    assert_eq!(20, f(20).unwrap());
}

#[inline(never)]
#[no_panic]
#[test]
fn do_not_panic_with_expect() {
    assert_eq!(21, f(21).expect("unreachable"));
}

#[inline(never)]
#[no_panic]
#[test]
fn do_not_panic_with_unwrap_unchecked() {
    assert_eq!(1, unsafe { f(1).unwrap_unchecked() });
}

// no_alloc

//https://github.com/Windfisch/rust-assert-no-alloc/issues/11

#[test]
#[should_panic]
fn does_actually_alloc() {
    assert_no_alloc(|| {
        let xs: Vec<i64> = Vec::with_capacity(42);
        assert_eq!(42, xs.capacity());
    });
}

#[test]
fn does_not_alloc() {
    assert_no_alloc(|| {
        let xs: Vec<i64> = Vec::with_capacity(0);
        assert_eq!(0, xs.capacity());
    });
}
