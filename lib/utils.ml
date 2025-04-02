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

let int_to_exponent (input : int) : string =
  let rec go output_string = function
    | 0 -> output_string
    | num -> 
      let take_value value =
        let ones = value mod 10 in
        let other = value - ones in
        let find_exp n = 
          match n with
          | 0 -> "⁰"
          | 1 -> "¹"
          | 2 -> "²"
          | 3 -> "³"
          | 4 -> "⁴"
          | 5 -> "⁵"
          | 6 -> "⁶"
          | 7 -> "⁷"
          | 8 -> "⁸"
          | 9 -> "⁹"
          | _ -> assert false
        in
        find_exp ones, other
      in
      match take_value num with
      | (expon, other) -> go (expon ^ output_string) (other / 10)
  in
  go "" input