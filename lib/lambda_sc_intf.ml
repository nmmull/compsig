type bop = Add | Mul | Comp

type expr =
  | Float of float
  | Ident
  | Sin of {
      freq: expr;
      phase: expr;
    }
  | Bop of bop * expr * expr
  | Pow of expr * int
  | Var of string
  | Let of string * expr * expr
