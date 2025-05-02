type ty =
  | SignalTy
  | FunTy of ty * ty

type bop = Add | Mul | Comp

type expr =
  | Float of float
  | Ident
  | Noise
  | Sin
  | Triangle
  | Saw
  | Square
  | Bop of bop * expr * expr
  | Var of string
  | Fun of string * ty * expr
  | App of expr * expr
  | Let of string * expr * expr
