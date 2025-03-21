module type COEFFICIENT = sig
  type t
  include Utils.COMPARE with type t := t
  include Utils.PP with type t := t
  include Utils.RING with type t := t
end

module type POLYNOMIAL = sig
  type base
  type monomial
  type coefficient
  type t

  include Utils.COMPARE with type t := t
  include Utils.PP with type t := t
  include Utils.RING with type t := t

  val of_list : (coefficient * monomial) list -> t
  val to_list : t -> (coefficient * monomial) list
  val fold : (coefficient -> monomial -> 'acc -> 'acc) -> t -> 'acc -> 'acc

  val of_coefficient : coefficient -> t
  val of_monomial : monomial -> t
  val of_base : base -> t

  val comp_mono : (base -> t -> t) -> monomial -> t -> t
  val comp : (base -> t -> t) -> t -> t -> t
end

module type MAKER =
  functor (C : COEFFICIENT) (B : Utils.BASE) ->
  POLYNOMIAL
  with type coefficient = C.t
  with type base = B.t
  with type monomial = Monomial.Make(B).t

module type Intf = sig
  module type COEFFICIENT = COEFFICIENT
  module type MAKER = MAKER
  module Make : MAKER
end
