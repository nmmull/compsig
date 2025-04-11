open Syntax

module type Intf = sig
  type 'a base_signal =
    | Ident
    | Sin of 'a
  type t
  include Utils.COMPARE with type t := t
  include Utils.PP with type t := t
  include Utils.RING with type t := t

  val ident : t
  val sin : t -> t
  val const : float -> t

  val to_expr : t -> expr
  val of_expr : expr -> t

  val linearize : t -> t * t

  val comp_base : t base_signal -> t -> t
  val comp : t -> t -> t
end
