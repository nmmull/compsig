module type MONOMIAL = sig
  type base
  type t
  include Utils.COMPARE with type t := t
  include Utils.PP with type t := t
  include Utils.MUL_MONOID with type t := t

  val of_list : (base * int) list -> t
  val to_list : t -> (base * int) list
  val fold : (base -> int -> 'acc -> 'acc) -> t -> 'acc -> 'acc
end

module type MAKER = functor (B : Utils.BASE) -> MONOMIAL with type base = B.t

module type Intf = sig
  module type MAKER = MAKER
  module Make : MAKER
end
