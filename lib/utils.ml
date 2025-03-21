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

let is_close f1 f2 = Float.(abs (f1 -. f2) < epsilon)
