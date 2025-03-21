open Alcotest

module P = Compsig.Polynomial.Make(Compsig.Polynomial.IntCoefficient)

let poly = testable P.pp P.equal

let test_add_basic () =
  let p1 = P.of_list [(12, 0); (4, 1); (3, 2)] in
  let p2 = P.of_list [(1, 0); (3, 2); (2, 3)] in
  let expected = P.of_list [(13, 0); (4, 1); (6, 2); (2, 3)] in
  check poly
    "(3x² + 4x + 12) + (2x³ + 3x² + 1) = 2x³ + 6x² + 4x + 13"
    expected
    P.(p1 + p2)

let test_mul_basic () =
  let p = P.of_list [(1, 1); (5, 0)] in
  let expected = P.of_list [(1, 2); (10, 1); (25, 0)] in
  check poly
    "(x + 5)² = x² + 10x + 25"
    expected
    P.(p * p)

let test_pow_basic () =
  let p = P.of_list [(1, 1); (2, 0)] in
  let expected = P.of_list [(1, 3); (6, 2); (12, 1); (8, 0)] in
  check poly
    "(x + 2)³ = x³ + 6x² + 12x + 8"
    expected
    P.(p ^ 3)

let test_comp_basic () =
  let p = P.of_list [(1, 2); (2, 0)] in
  let expected = P.((p ^ 2) + const 2) in
  check poly
    "(x² + 2) << (x² + 2) = (x² + 2)² + 2"
    expected
    P.(p << p)

let test_factor_basic () =
  let p = P.of_list [(2, 3); (-3, 2); (14, 0)] in
  let expected = (P.of_list [(2, 2); (-3, 1)], 14) in
  check (pair poly int)
    "2x³ - 3x² + 14 = (2x² - 3x)x + 14"
    expected
    (P.factor_t p)

let tests =
  [
    test_case "basic add test" `Quick test_add_basic;
    test_case "basic mul test" `Quick test_mul_basic;
    test_case "basic pow test" `Quick test_pow_basic;
    test_case "basic comp test" `Quick test_comp_basic;
    test_case "basic factor test" `Quick test_factor_basic;
  ]
