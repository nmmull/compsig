open Alcotest

module Variable = Test_monomial.Variable

module P = Compsig.Polynomial.Make(Compsig.Utils.IntCoefficient)(Variable)
module M = Compsig.Monomial.Make(Variable)

let poly =
  let module T = Compsig.Utils.Testable(P) in
  T.testable

let test_zero () =
  let expected = P.zero in
  let actual =P.of_list [] in
  check poly
    "of_list [] = 0"
    expected
    actual

let test_one () =
  let expected = P.one in
  let actual = P.of_list [(1, M.one)] in
  check poly
    "1 = 1 * 1"
    expected
    actual

let test_add () =
  let m1 = M.of_list [(X, 2)] in
  let m2 = M.of_list [(Y, 3)] in
  let p1 = P.of_list [(2, m1)] in
  let p2 = P.of_list [(5, m2)] in
  let expected = P.of_list [(2, m1); (5, m2)] in
  let actual = P.add p1 p2 in
  check poly
    "add 2X² 5Y³ = 2X² + 5Y³"
    expected
    actual

let test_mul () =
  let x = M.of_list [X, 1] in
  let p = P.of_list [(1, x); (1, M.one)] in
  let expected = P.of_list [(1, M.mul x x); (2, x); (1, M.one)] in
  let actual = P.mul p p in
  check poly
    "(X + 1)² = X² + 2X + 1"
    expected
    actual

let test_zero_coefficient () =
  let x = M.of_list [X, 1] in
  let expected = P.of_list [(5, x)] in
  let actual = P.of_list [(0, x); (5, x)] in
  check poly
    "0X + 5X = 5X"
    expected
    actual

let tests =
  [
    test_case "basic zero test" `Quick test_zero;
    test_case "basic one test" `Quick test_one;
    test_case "basic add test" `Quick test_add;
    test_case "basic mul test" `Quick test_mul;
    test_case "basic zero coefficient test" `Quick test_zero_coefficient;
  ]
