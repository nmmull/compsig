type 'a base_signal =
  | Ident
  | Sin of 'a

module rec P : Polynomial_intf.POLYNOMIAL
  with type coefficient = float
  with type base = Base.t
  with type monomial = Monomial.Make(Base).t
  = Polynomial.Make(Utils.FloatCoefficient)(Base)
and Base : Utils.BASE with type t = P.t base_signal = struct
  type t = P.t base_signal

  let compare b1 b2 =
    match b1, b2 with
    | Ident, Ident -> 0
    | Ident, _ -> -1
    | _, Ident -> 1
    | Sin p1, Sin p2 -> P.compare p1 p2

  let to_string = function
    | Ident -> "t"
    | Sin signal -> "sin(" ^ Fmt.to_to_string P.pp signal ^ ")"

  let pp = Fmt.of_to_string to_string
end

include P
module M = Monomial.Make(Base)

let ident = P.of_base Ident
let sin signal = P.of_base (Sin signal)
let const = P.of_coefficient

let rec comp_base base signal =
  match base with
  | Ident -> signal
  | Sin p1 -> P.of_base (Sin (P.comp comp_base p1 signal))

let comp = P.comp comp_base

let rec to_expr s =
  let expr_of_mon (c, m) =
    let m = monomial_to_expr m in
    if c = 1.
    then m
    else Syntax.Prod [Syntax.Const c; m]
  in
  s
  |> P.to_list
  |> List.map expr_of_mon
  |> List.filter ((<>) (Syntax.Const 0.))
  |> fun l -> Syntax.Sum l
and monomial_to_expr mono =
  mono
  |> M.to_list
  |> List.map (fun (b, e) -> Syntax.Pow (base_signal_to_expr b, e))
  |> fun l -> Syntax.Prod l
and base_signal_to_expr = function
  | Ident -> Syntax.Ident
  | Sin s -> Syntax.Sin (to_expr s)
