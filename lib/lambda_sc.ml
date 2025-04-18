include Lambda_sc_parser.Syntax

let parse s =
  let open Lambda_sc_parser in
  match Parser.prog Lexer.read (Lexing.from_string s) with
  | expr -> Some expr
  | exception _ -> None

module Env = Map.Make(String)

type ty =
  | SignalTy
  | FunTy of ty * ty

type value =
  | VClos of string * expr * value Env.t
  | VSignal of Signal.t

exception UnexpectedError

let rec type_of ctxt e =
  let open Signal in
  let rec go e = function
    | Float _ -> Some SignalTy
    | Ident -> Some SignalTy
    | Sin -> Some SignalTy
    | Bop (op, e1, e2) -> (
       match go e1, go e2 with
       | Some SignalTy, Some SignalTy -> Some SignalTy
       | _ -> None
    )
    |



let rec eval env =
  let open Signal in
  let rec go = function
    | Float f -> VSignal (const f)
    | Ident -> VSignal ident
    | Sin -> VSignal (sin ident)
    | Bop (bop, e1, e2) -> (
       match go e1, go e2 with
       | VSignal s1, VSignal s2 -> (
          match bop with
          | Add -> VSignal (add s1 s2)
          | Mul -> VSignal (mul s1 s2)
          | Comp -> VSignal (comp s1 s2)
       )
       | _ -> raise UnexpectedError
    )
    | Var x -> Env.find x env (* TODO: Better error handling *)
    | Fun (x, e) -> VClos (x, e, env)
    | App (e1, e2) -> (
       match go e1 with
       | VClos (x, e, env) -> eval (Env.add x (go e2) env) e
       | _ -> raise UnexpectedError
    )
  in go

let eval e =
  match eval Env.empty e with
  | VSignal s -> s
  | _ -> raise UnexpectedError
