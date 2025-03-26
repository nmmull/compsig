
let () =
  let open Alcotest in
  run "Compsig test suite"
    [
      "monomial-tests", Test_monomial.tests;
      "polynomial-tests", Test_polynomial.tests;
      "signal-tests", Test_signal.tests;
    ]
