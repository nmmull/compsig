type expr
  = Ident
  | Sin
  | Const of float
  | Comp of expr * expr
  | Add of expr * expr
  | Mul of expr * expr
