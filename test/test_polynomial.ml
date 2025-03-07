open Compsig.Polynomial
open Alcotest

let test_num_terms_empty () =
  check int
    "empty has no terms"
    0
    (num_terms empty)

let test_num_terms_monomial () =
  check int
    "monomial has one terms"
    1
    (num_terms (monomial 23.4 40))

let tests =
  [
    test_case "empty has 0 terms" `Quick test_num_terms_empty;
    test_case "monomial has 1 term" `Quick test_num_terms_monomial;
  ]
