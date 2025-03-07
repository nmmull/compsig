open Compsig.Polynomial
open Alcotest

let test_empty () =
  Alcotest.(check int)
    "empty has no terms"
    0
    (num_terms empty)

let tests =
  [
    test_case "empty" `Quick test_empty;
  ]
