type 'a base_signal =
  | Ident
  | Sin of 'a
  | Triangle of 'a
  | Saw of 'a
  | Square of 'a
  | Noise of 'a

module rec P : Polynomial_intf.POLYNOMIAL
          with type coefficient = float
          with type base = Base.t
          with type monomial = Monomial.Make(Base).t
  = Polynomial.Make(Utils.FloatCoefficient)(Base)
  and Base : Utils.BASE with type t = P.t base_signal = struct
    type t = P.t base_signal

    let order_base_signal p =
      match p with
      | Ident -> -1
      | Sin _ -> 0
      | Triangle _ -> 1
      | Saw _ -> 2
      | Square _ -> 3
      | Noise _ -> 4
    
    let extract_poly p =
      match p with
      | Ident -> assert false
      | Sin x -> x
      | Triangle x -> x
      | Saw x -> x
      | Square x -> x
      | Noise x -> x

    let compare b1 b2 =
      match b1, b2 with
      | Ident, Ident -> 0
      | Ident, _ -> -1
      | _, Ident -> 1
      | p1, p2 -> 
          let x1 = order_base_signal p1 in
          let x2 = order_base_signal p2 in
          if x1 < x2 then
            1
          else if x1 > x2 then
            -1
          else
            P.compare (extract_poly p1) (extract_poly p2)

    let pp = Fmt.nop
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
  | Triangle p1 -> P.of_base (Triangle (P.comp comp_base p1 signal))
  | Saw p1 -> P.of_base (Saw (P.comp comp_base p1 signal))
  | Square p1 -> P.of_base (Square (P.comp comp_base p1 signal))
  | Noise p1 -> P.of_base (Noise (P.comp comp_base p1 signal))

let comp = P.comp comp_base

let rec linearize (s : t) =
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
  | Const f -> const f
  | Sin e -> sin (of_expr e)
  | Sum es -> List.fold_left P.add P.zero (List.map of_expr es)
  | Prod es -> List.fold_left P.mul P.one (List.map of_expr es)

let rec to_expr (s : t) =
  s
  |> P.to_list
  |> List.map (fun (c, m) ->
        let m = monomial_to_expr m in
        if c = 1.
        then m
        else Syntax.Prod [Syntax.Const c; m])
  |> List.filter ((<>) (Syntax.Const 0.))
  |> fun l -> Syntax.Sum l
and monomial_to_expr mono =
  mono
  |> M.to_list
  |> List.map (fun (b, e) -> Syntax.Prod (List.init e (fun _ -> base_signal_to_expr b)))
  |> fun l -> Syntax.Prod l
and base_signal_to_expr = function
  | Ident -> Syntax.Ident
  | Sin s -> Syntax.Sin (to_expr s)
  | Triangle s -> Syntax.Triangle (to_expr s)
  | Saw s -> Syntax.Saw (to_expr s)
  | Square s -> Syntax.Square (to_expr s)
  | Noise s -> Syntax.Noise (to_expr s)
