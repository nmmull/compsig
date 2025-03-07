module M = Map.Make(Int)

type t = float M.t (* map exponents to coefficients *)

let empty = M.empty
let const value = M.singleton 0 value
let monomial coeff exp = M.singleton exp coeff
let line slope = monomial slope 1

let num_terms poly = M.cardinal poly
