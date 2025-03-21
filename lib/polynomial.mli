module type Coefficient = sig
  type t
  val compare : t -> t -> int
  val equal : t -> t -> bool
  val pp : t Fmt.t
  val zero : t
  val one : t
  val add : t -> t -> t
  val mul : t -> t -> t
end


module Monomial : sig
  module type Base = sig
    type t
    val compare : t -> t -> int
    val pp : t Fmt.t
  end
  module Make :
  functor (T : Base) -> sig
    type t
    val of_list : (T.t * int) list -> t
    val to_list : t -> (T.t * int) list
    val compare : t -> t -> int
    val equal : t -> t -> bool
    val pp : t Fmt.t
    val one : t
    val mul : t -> t -> t
    val pow : t -> int -> t

    val ( * ) : t -> t -> t
    val (^) : t -> int -> t
  end
end

module Make :
functor (C : Coefficient) (T : Monomial.Base) -> sig
  type t
  val of_list : (C.t * Monomial.Make(T).t) list -> t
  val to_list : t -> (C.t * Monomial.Make(T).t) list
  val compare : t -> t -> int
  val equal : t -> t -> bool
  val pp : t Fmt.t
  val zero : t
  val one : t
  val add : t -> t -> t
  val mul : t -> t -> t
  val pow : t -> int -> t
  val comp_mono : (T.t -> t -> t) -> C.t -> Monomial.Make(T).t -> t -> t
  val comp : (T.t -> t -> t) -> t -> t -> t
  val (+) : t -> t -> t
  val ( * ) : t -> t -> t
  val (^) : t -> int -> t
end
