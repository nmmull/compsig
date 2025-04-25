type ident = string

type bop = Add | Mul

type expr =
  | Var of ident
  | Float of float
  | Bop of bop * expr * expr
  | SinOsc of {
      freq: expr;
      phase: expr;
      mul: expr;
      add: expr;
    }
  | Block of prog * expr

and stmt =
  | Expr of expr
  | Assign of ident * expr

and prog = stmt list
