
let () =
  let open Alcotest in
  run "Compsig test suite"
    [
     "polynomial-tests", Test_polynomial.tests
    ]
