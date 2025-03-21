module FloatCoefficient : Polynomial.Coefficient

module Compound : sig
  type t
  val compare : t -> t -> int
  val pp : t Fmt.t
end

module Base : sig
  type t = Ident | Sin of Compound.t
  val compare : t -> t -> int
  val pp : t Fmt.t
end
