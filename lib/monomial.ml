include Monomial_intf

module Make (B : Utils.BASE) = struct
  module M = Map.Make(B)
  type t = int M.t
  type base = B.t

  let of_list l = M.of_list (List.filter (fun (_, n) -> n > 0) l)
  let to_list = M.to_list
  let of_base b = M.of_list [b, 1]
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

  let exponent base mono =
    match M.find_opt base mono with
    | Some n when n > 0 -> n
    | _ -> 0

  let compare = M.compare Int.compare
  let pp = Fmt.nop
end
