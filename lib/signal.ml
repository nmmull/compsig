type 'a base_signal =
  | Ident
  | Sin of 'a

module rec P : Polynomial_intf.POLYNOMIAL with type base = Base.t = Polynomial.Make(Utils.FloatCoefficient)(Base)
   and Base : Utils.BASE with type t = P.t base_signal = struct
     type t = P.t base_signal

     let compare b1 b2 =
       match b1, b2 with
       | Ident, Ident -> 0
       | Ident, _ -> -1
       | _, Ident -> 1
       | Sin p1, Sin p2 -> P.compare p1 p2

     let pp = Fmt.nop
   end

include P

let rec comp_base base signal =
  match base with
  | Ident -> signal
  | Sin p1 -> P.of_base (Sin (P.comp comp_base p1 signal))

let comp sig1 sig2 = P.comp comp_base sig1 sig2
