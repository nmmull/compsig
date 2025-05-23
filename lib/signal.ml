module FSignal = struct
  type t = [
    | `Sin
    | `Triangle
    | `Saw
    | `Square
  ]

  let to_string = function
    | `Sin -> "sin"
    | `Triangle -> "triangle"
    | `Saw -> "saw"
    | `Square -> "square"

  let to_expr s e =
    let open Syntax in
    match s with
    | `Sin -> Sin e
    | `Triangle -> Triangle e
    | `Saw -> Saw e
    | `Square -> Square e
end

type fsignal = FSignal.t
type 'a base_signal =
  | Ident
  | Noise
  | FSignal of fsignal * 'a

module rec P : Polynomial_intf.POLYNOMIAL
  with type coefficient = float
  with type base = Base.t
  with type monomial = Monomial.Make(Base).t
  = Polynomial.Make(Utils.FloatCoefficient)(Base)
and Base : Utils.BASE with type t = P.t base_signal = struct
  type t = P.t base_signal

  let compare b1 b2 =
    match b1, b2 with
    | Ident, Ident | Noise, Noise -> 0
    | Ident, _ -> -1
    | _, Ident -> 1
    | Noise, _ -> -1
    | _, Noise -> 1
    | FSignal (k1, p1), FSignal (k2, p2) ->
      if k1 < k2
      then -1
      else if k1 = k2
      then P.compare p1 p2
      else 1

  let to_string = function
    | Ident -> "t"
    | Noise -> "noise()"
    | FSignal (s, signal) ->
      String.concat ""
        [
          FSignal.to_string s;
          "(";
          Fmt.to_to_string P.pp signal;
          ")";
        ]

  let pp = Fmt.of_to_string to_string
end

include P
module M = Monomial.Make(Base)

let ident = P.of_base Ident
let noise = P.of_base Noise
let sin signal = P.of_base (FSignal (`Sin, signal))
let triangle signal = P.of_base (FSignal (`Triangle, signal))
let saw signal = P.of_base (FSignal (`Saw, signal))
let square signal = P.of_base (FSignal (`Square, signal))
let const = P.of_coefficient

let rec comp_base base signal =
  match base with
  | Ident -> signal
  | Noise -> P.of_base Noise
  | FSignal (s, p) -> P.of_base (FSignal (s, P.comp comp_base p signal))

let comp = P.comp comp_base

let rec linearize s =
  let combiner coeff mono (has_t, no_t) =
    let (mon_has_t, mon_no_t) = linearize_mono mono in
    (
      P.add
        (P.mul (const coeff) mon_has_t)
        has_t
    , P.add
        (P.mul (const coeff) mon_no_t)
        no_t
    )
  in
  P.fold combiner s (P.zero, P.zero)
and linearize_mono mono =
  let l = M.to_list mono in
  let of_mono m =
    m
    |> M.of_list
    |> P.of_monomial
  in
  let rec go acc = function
    | [] -> (const 0., of_mono acc)
    | (Ident, n) :: l -> (of_mono ((Ident, n - 1) :: l @ acc), const 0.)
    | t :: l -> go (t :: acc) l
  in go [] l

let rec of_expr e =
  let open Syntax in
  match e with
  | Ident -> ident
  | Noise -> noise
  | Const f -> const f
  | Sin e -> sin (of_expr e)
  | Triangle e -> triangle (of_expr e)
  | Saw e -> saw (of_expr e)
  | Square e -> square (of_expr e)
  | Sum es -> List.fold_left P.add P.zero (List.map of_expr es)
  | Prod es -> List.fold_left P.mul P.one (List.map of_expr es)

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
  |> List.map (fun (b, e) -> Syntax.Prod (List.init e (fun _ -> base_signal_to_expr b)))
  |> fun l -> Syntax.Prod l
and base_signal_to_expr = function
  | Ident -> Syntax.Ident
  | Noise -> Syntax.Noise
  | FSignal (s, e) -> FSignal.to_expr s (to_expr e)
