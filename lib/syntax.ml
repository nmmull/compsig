
type expr =
  | Ident
  | Const of float
  | Sin of expr
  | Sum of expr list
  | Prod of expr list
  | Pow of expr * int
