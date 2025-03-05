#[test_only]
module memest::memest_tests;

use memest::memest;

#[test]
fun test_memest() {
    let sum = 2 + 2;
    assert!(sum == 4);
}
