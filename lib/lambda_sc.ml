include Lambda_sc_intf

let parse s =
  match Lambda_sc_parser.prog Lambda_sc_lexer.read (Lexing.from_string s) with
  | expr -> Some expr
  | exception _ -> None

module Env = Map.Make(String)

let rec eval env =
  let open Signal in
  let rec go = function
    | Float f -> const f
    | Ident -> ident
    | Sin {freq;phase} ->
       sin (add
              (mul (const (2. *. Float.pi)) (go freq))
              (go phase))
    | Bop (Add, e1, e2) -> add (go e1) (go e2)
    | Bop (Mul, e1, e2) -> mul (go e1) (go e2)
    | Bop (Comp, e1, e2) -> comp (go e1) (go e2)
    | Pow (e1, exp) ->
       let module M = Utils.Mul_monoid(Signal) in
       M.pow (go e1) exp
    | Var x -> Env.find x env (* TODO *)
    | Let(x, e1, e2) -> eval (Env.add x (go e1) env) e2
  in go
let eval = eval Env.empty
