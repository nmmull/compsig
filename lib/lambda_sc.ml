include Lambda_sc_parser.Syntax

let parse s =
  let open Lambda_sc_parser in
  match Parser.prog Lexer.read (Lexing.from_string s) with
  | expr -> Some expr
  | exception _ -> None

module Env = Map.Make(String)

type value =
  | VClos of string * expr * value Env.t
  | VSignal of Signal.t

exception UnexpectedError

let rec type_of ctxt =
  let rec go = function
    | Float _ | Ident
    | Sin | Noise | Triangle | Saw | Square -> Some SignalTy
    | Bop (_, e1, e2) -> (
       match go e1, go e2 with
       | Some SignalTy, Some SignalTy -> Some SignalTy
       | _ -> None
    )
    | Var x -> Env.find_opt x ctxt
    | App (e1, e2) -> (
      match go e1, go e2 with
      | Some FunTy (t1, t2), Some t3 when t1 = t3 -> Some t2
      | _ -> None
    )
    | Fun (x, ty, e) -> (
      match type_of (Env.add x ty ctxt) e with
      | Some t2 -> Some (FunTy (ty, t2))
      | _ -> None
    )
    | Let (x, e1, e2) ->
       match type_of ctxt e1 with
       | Some ty -> type_of (Env.add x ty ctxt) e2
       | _ -> None
  in go

let rec eval env =
  let open Signal in
  let rec go = function
    | Float f -> VSignal (const f)
    | Ident -> VSignal ident
    | Sin -> VSignal (sin ident)
    | Noise -> VSignal noise
    | Triangle -> VSignal (triangle ident)
    | Saw -> VSignal (saw ident)
    | Square -> VSignal (square ident)
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
    | Fun (x, _, e) -> VClos (x, e, env)
    | App (e1, e2) -> (
       match go e1 with
       | VClos (x, e, env) -> eval (Env.add x (go e2) env) e
       | _ -> raise UnexpectedError
    )
    | Let (x, e1, e2) -> eval (Env.add x (go e1) env) e2
  in go

let eval e =
  match eval Env.empty e with
  | VSignal s -> s
  | _ -> raise UnexpectedError

exception ParseError
exception TypeError

let interp str =
  match parse str with
  | Some e -> (
    match type_of Env.empty e with
    | Some SignalTy -> eval e
    | _ -> raise TypeError
  )
  | _ -> raise ParseError
