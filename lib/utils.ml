module type COMPARE = sig
  type t
  val compare : t -> t -> int
end

module type PP = sig
  type t
  val pp : t Fmt.t
end

module type BASE = sig
  type t
  include COMPARE with type t := t
  include PP with type t := t
end

module type MUL_MONOID = sig
  type t
  val one : t
  val mul : t -> t -> t
end

module type ADD_MONOID = sig
  type t
  val zero : t
  val add : t -> t -> t
end
module type RING = sig
  type t
  include ADD_MONOID with type t := t
  include MUL_MONOID with type t := t
end

module Mul_monoid (M : MUL_MONOID) = struct
  let pow poly exp =
    if exp < 0
    then raise (Invalid_argument "cannot take negative ring power")
    else
      let rec go acc n =
        if n = 0
        then acc
        else go (M.mul acc poly) (n - 1)
      in go M.one exp
end

module Compare (C : COMPARE) = struct
  let equals x y = C.compare x y = 0
end

module Testable(B : BASE) = struct
  let testable =
    let module C = Compare(B) in
    Alcotest.testable B.pp C.equals
end

module FloatCoefficient = struct
  include Float
  let pp = Fmt.float
  let compare f1 f2 =
    if f1 -. f2 > epsilon
    then 1
    else if f2 -. f1 > epsilon
    then -1
    else 0
end

module IntCoefficient = struct
  include Int
  let pp = Fmt.nop
end
