include Polynomial_intf

module Make (C : COEFFICIENT) (B : Utils.BASE) = struct
  module M = Monomial.Make(B)
  module P = Map.Make(M)

  type coefficient = C.t
  type base = B.t
  type monomial = M.t
  type t = C.t P.t (* map exponents to coefficients *)

  let of_list l =
    let module CC = Utils.Compare(C) in
    l
    |> List.filter (fun (c, _) -> not (CC.equals c C.zero))
    |> List.map (fun (x, y) -> (y, x))
    |> P.of_list

  let to_list p =
    p
    |> P.to_list
    |> List.sort (fun (exp1,_) (exp2,_) -> M.compare exp2 exp1)
    |> List.map (fun (x, y) -> (y, x))

  let of_monomial m = P.of_list [m, C.one]
  let of_base b = P.of_list [M.of_list [b, 1], C.one]
  let of_coefficient c = of_list [c, M.one]

  let compare = P.compare C.compare
  let pp = Fmt.nop

  let fold accum = P.fold (fun mon coeff -> accum coeff mon)

  let zero = of_list []
  let one = of_list [C.one, M.one]

  let add poly1 poly2 =
    let combiner _ coeff1 coeff2 =
      match coeff1, coeff2 with
      | _, None -> coeff1
      | None, _ -> coeff2
      | Some c1, Some c2 -> Some (C.add c1 c2)
    in
    P.merge combiner poly1 poly2

  let mul_poly_mon poly coeff mon =
    let accumulator next_coeff next_mon acc_poly =
      let updater curr_coeff =
        Some
          (C.add
             (Option.value ~default:C.zero curr_coeff)
             (C.mul next_coeff coeff))
      in
      P.update (M.mul (next_mon) mon) updater acc_poly
    in fold accumulator poly zero

  let mul poly1 poly2 =
    List.fold_left add zero
      (List.map
         (fun (coeff, exp) -> mul_poly_mon poly1 coeff exp)
         (to_list poly2))

  module Mul_monoid = struct
    type t = C.t P.t
    let one = one
    let mul = mul
  end

  let comp_mono f mono poly =
    let module R = Utils.Mul_monoid(Mul_monoid) in
    M.fold
      (fun base exp acc -> mul (R.pow (f base poly) exp) acc)
      mono
      one

  let comp f poly1 poly2 =
    fold
      (fun coeff mono acc -> add (mul (of_coefficient coeff) (comp_mono f mono poly2)) acc)
      poly1
      zero
end
