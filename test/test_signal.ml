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

let test_expr () =
  let e1 =
    Comp
      ( Add
          ( Mul (Const 2., Mul (Ident, Ident))
          , Comp (Sin, Mul (Const 2., Ident))
          )
      , Add (Ident, (Const 1.))
      )
  in
  let e2 =
    Add
      ( Mul (Const 2., Mul (Ident, Ident))
      , Add
         ( Mul (Const 4., Ident)
         , Add
            ( Const 2.
            , Comp
                ( Sin
                , Add
                    ( Mul (Const 3., Ident)
                    , Const 3.
                    )
                )
            )
         )
      )
  in
  check signal
    "(2T² + sin(3T)) ∘ (T + 1) = 2T² + 4T + 2 + sin(3T + 3)"
    (S.of_expr e1)
    (S.of_expr e2)

let tests =
  [
    test_case "basic add mul test" `Quick test_double;
    test_case "basic comp test" `Quick test_comp;
    test_case "not so basic expr test" `Quick test_expr;
  ]
