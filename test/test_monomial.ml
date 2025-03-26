open Alcotest

module Variable = struct
  type t = X | Y | Z

  let compare v1 v2 =
    if v1 < v2
    then -1
    else if v1 = v2
    then 0
    else 1

  let pp = Fmt.nop
end

module M = Compsig.Monomial.Make(Variable)

let mono =
  let module T = Compsig.Utils.Testable(M) in
  T.testable

let test_one () =
  let expected = M.one in
  let actual = M.of_list [] in
  check mono
    "of_list [] = M.one"
    expected
    actual

let test_mul_basic () =
  let m1 = M.of_list [(X, 2)] in
  let m2 = M.of_list [(Y, 3)] in
  let expected = M.of_list [(X, 2); (Y, 3)] in
  let actual = M.mul m1 m2 in
  check mono
    "X² * Y³ = X²Y³"
    expected
    actual

let test_of_list () =
  let m = M.of_list [(X, 2); (X, 6); (Z, 2); (Y, 2)] in
  let m_again = M.of_list (M.to_list m) in
  check mono
    "of_list ∘ to_list = id"
    m
    m_again

let test_of_list_zero () =
  let m1 = M.of_list [(X, 0); (Y, 1)] in
  let m2 = M.of_list [(Y, 1)] in
  check mono
    "X⁰Y = Y"
    m1
    m2

let test_fold () =
  let m = M.of_list [(X, 4); (Y, 4); (Z, 5)] in
  let expected = 13 in
  let actual = M.fold (fun _ n acc -> acc + n) m 0 in
  check int
    "exponent_sum(X⁴Y⁴Z⁵) = 13"
    expected
    actual

let tests =
  [
    test_case "basic one test" `Quick test_one;
    test_case "basic multiplication test" `Quick test_mul_basic;
    test_case "basic of_list to_list test" `Quick test_of_list;
    test_case "basic zero exponent test" `Quick test_of_list_zero;
    test_case "basic fold test" `Quick test_fold;
  ]
