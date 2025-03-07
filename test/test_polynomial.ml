open Alcotest

module P = Compsig.Polynomial

let poly = testable P.pp P.equal

let test_num_terms_empty () =
  check int
    "empty has no terms"
    0
    P.(num_terms empty)

let test_num_terms_monomial () =
  check int
    "monomial has one terms"
    1
    P.(num_terms (monomial 23.4 40))

let test_dumb () =
  check poly
    "empty is empty"
    P.empty
    P.(monomial 23.4 40)

let tests =
  [
    test_case "empty has 0 terms" `Quick test_num_terms_empty;
    test_case "monomial has 1 term" `Quick test_num_terms_monomial;
    test_case "empty is empty" `Quick test_dumb;
  ]
