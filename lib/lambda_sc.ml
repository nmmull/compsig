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
    | Float _ -> Some SignalTy
    | Ident -> Some SignalTy
    | Sin -> Some SignalTy
    | Bop (_, e1, e2) ->
       if type_check ctxt (e1, SignalTy) && type_check ctxt (e2, SignalTy)
       then Some SignalTy
       else None
    | Var x -> Env.find_opt x ctxt
    | App (e1, e2) -> (
      match go e1 with
      | Some FunTy (t1, t2) ->
         if type_check ctxt (e2, t1)
         then Some t2
         else None
      | _ -> None
    )
    | Fun (x, e) -> type_of (Env.add x SignalTy ctxt) e
    | Let (x, ty, e1, e2) ->
       if type_check ctxt (e1, ty)
       then type_of (Env.add x ty ctxt) e2
       else None
  in go
and type_check ctxt =
  let go = function
    | Fun (x, e), FunTy (a, b) -> type_check (Env.add x a ctxt) (e, b)
    | e, ty -> (
      match type_of ctxt e with
      | Some ty' -> ty' = ty
      | _ -> false
    )
  in go

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
    | Let (x, _, e1, e2) -> eval (Env.add x (go e1) env) e2
  in go

let eval e =
  match eval Env.empty e with
  | VSignal s -> s
  | _ -> raise UnexpectedError

let interp str =
  let ( let* ) = Option.bind in
  let* e = parse str in
  if type_check Env.empty (e, SignalTy)
  then Some (eval e)
  else None
