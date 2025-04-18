
type expr =
  | Ident
  | Const of float
  | Sin of expr
  | Triangle of expr
  | Saw of expr
  | Square of expr
  | Noise of expr
  | Sum of expr list
  | Prod of expr list
