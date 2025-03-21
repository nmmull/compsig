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

module Monomial = struct
  module type Base = sig
    type t
    val compare : t -> t -> int
    val pp : t Fmt.t
  end

  module Make (T : Base) = struct
    module M = Map.Make(T)
    type t = int M.t

    let of_list = M.of_list
    let to_list = M.to_list
    let fold = M.fold

    let one = M.empty

    let mul mon1 mon2 =
      let combiner _ exp1 exp2 =
        match exp1, exp2 with
        | _, None -> exp1
        | None, _ -> exp2
        | Some exp1, Some exp2 -> Some (exp1 + exp2)
      in
      M.merge combiner mon1 mon2

    let compare = M.compare Int.compare
    let equal = M.equal Int.equal
    let pp = Fmt.nop

    let pow mon n =
      M.filter_map
        (fun _ exp -> if n = 0 then None else Some (exp * n))
        mon

    let ( * ) = mul
    let ( ^ ) = pow
  end
end

module Make (C : Coefficient) (T : Monomial.Base) = struct
  module S = Monomial.Make(T)
  module M = Map.Make(S)

  type t = C.t M.t (* map exponents to coefficients *)

  let of_list l = M.of_list (List.map (fun (x, y) -> (y, x)) l)
  let to_list p =
    p
    |> M.to_list
    |> List.sort (fun (exp1,_) (exp2,_) -> S.compare exp2 exp1)
    |> List.map (fun (x, y) -> (y, x))

  let zero = of_list []
  let one = of_list [C.one, S.one]
  let const c = of_list [c, S.one]

  let compare = M.compare C.compare
  let equal = M.equal C.equal

  let fold accum = M.fold (fun mon coeff -> accum coeff mon)

  let pp : t Fmt.t =
    Fmt.using to_list
      (Fmt.list
         ~sep:(Fmt.const Fmt.string " + ")
         (Fmt.pair
            C.pp
            S.pp))

  let add poly1 poly2 =
    let combiner _ coeff1 coeff2 =
      match coeff1, coeff2 with
      | _, None -> coeff1
      | None, _ -> coeff2
      | Some c1, Some c2 -> Some (C.add c1 c2)
    in
    M.merge combiner poly1 poly2

  let mul_poly_mon poly coeff mon =
    let accumulator next_coeff next_mon acc_poly =
      let updater curr_coeff =
        Some
          (C.add
             (Option.value ~default:C.zero curr_coeff)
             (C.mul next_coeff coeff))
      in
      M.update (S.mul (next_mon) mon) updater acc_poly
    in fold accumulator poly zero

  let mul poly1 poly2 =
    List.fold_left add zero
      (List.map
         (fun (coeff, exp) -> mul_poly_mon poly1 coeff exp)
         (to_list poly2))

  let pow poly exp =
    if exp < 0
    then raise (Invalid_argument "cannot take negative power of polynomial")
    else
      let rec go acc n =
        if n = 0
        then acc
        else go (mul acc poly) (n - 1)
      in go one exp

  let comp_mono f coeff mono poly =
    S.fold
      (fun base exp acc -> mul (mul (const coeff) (pow (f base poly) exp)) acc)
      mono
      one

  let comp f poly1 poly2 =
    fold
      (fun coeff mono acc -> add (comp_mono f coeff mono poly2) acc)
      poly1
      zero

  let _coefficient exp poly = Option.value ~default:C.zero (M.find_opt exp poly)
  let _factor_t _poly = assert false

  let (+) = add
  let ( * ) = mul
  let (^) = pow
end
