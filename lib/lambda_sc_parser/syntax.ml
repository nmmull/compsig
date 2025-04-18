type bop = Add | Mul | Comp

type expr =
  | Float of float
  | Ident
  | Sin
  | Bop of bop * expr * expr
  | Var of string
  | Fun of string * expr
  | App of expr * expr
