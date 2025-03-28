open Alcotest
open Compsig
module S = Signal

let signal =
  let module T = Utils.Testable(S) in
  T.testable

let test_double () =
  let s1 = S.(add (sin ident) (sin ident)) in
  let s2 = S.(mul (const 2.) (sin ident)) in
  check signal
    "sin(T) + sin(T) = 2 * sin(T)"
    s1
    s2

let test_comp () =
  let s1 = S.(comp
                (sin (mul (const 2.) ident))
                (mul (const 2.) ident)) in
  let s2 = S.(sin (mul (const 4.) ident)) in
  check signal
    "sin(2T) ∘ 2T = sin(4T)"
    s1
    s2

let test_complex_poly () =
  let open Signal in
  let s1 =
    comp
      (mul (const 2.) (mul ident ident))
      (add ident (const 1.))
  in
  let s2 =
    add
      (mul (const 2.) (mul ident ident))
      (add
        (mul (const 4.) ident)
        (const 2.))
  in
  check signal
    "2T² ∘ (T + 1) = 2T² + 4T + 2"
    s1
    s2

let test_complex_sin () =
  let open Signal in
  let s1 =
    comp
      (sin (mul (const 3.) ident))
      (add ident (const 1.))
  in
  let s2 =
    (sin
       (add
          (mul (const 3.) ident)
          (const 3.)))
  in
  check signal
    "sin(3T) ∘ (T + 1) = sin(3T + 3)"
    s1
    s2

let test_complex () =
  let open Signal in
  let s1 =
    comp
      (add
        (mul (const 2.) (mul ident ident))
        (sin (mul (const 3.) ident)))
      (add ident (const 1.))
  in
  let s2 =
    add
      (mul (const 2.) (mul ident ident))
      (add
        (mul (const 4.) ident)
        (add
           (const 2.)
           (sin
              (add
                 (mul (const 3.) ident)
                 (const 3.)))))
  in
  check signal
    "(2T² + sin(3T)) ∘ (T + 1) = 2T² + 4T + 2 + sin(3T + 3)"
    s1
    s2

let tests =
  [
    test_case "basic add mul test" `Quick test_double;
    test_case "basic comp test" `Quick test_comp;
    test_case "not so basic poly comp test" `Quick test_complex_poly;
    test_case "not so basic sin comp test" `Quick test_complex_sin;
    test_case "not so basic signal test" `Quick test_complex;
  ]
