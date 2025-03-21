module FloatCoefficient = struct
  include Float
  let pp = Fmt.nop
end

module rec P : sig
         type t
       end = Polynomial.Make (FloatCoefficient) (Base)
   and Base : sig
     type t
     val compare : t -> t -> int
     val pp : t Fmt.t
   end = struct

     type t =
       | Ident
       | Sin of P.t

  let compare _ _ = assert false
  let pp = Fmt.nop
end

module rec Compound: sig
         type t
         val compare : t -> t -> int
         val pp : t Fmt.t
         val comp : Compound.t -> Compound.t -> Compound.t
       end = struct
  module P = Polynomial.Make (FloatCoefficient) (Base)
  type t = P.t

  let compare sig1 sig2 = P.compare sig1 sig2
  let pp = Fmt.nop

  let comp s1 s2 = P.comp Base.comp_base_sig s1 s2
end and Base : sig
         type t
         val compare : t -> t -> int
         val pp : t Fmt.t
         val comp_base_sig : Base.t -> Compound.t -> Compound.t
       end = struct

  let rec comp_base_sig base signal =
    match base with
    | Ident -> signal
    | Sin inner -> comp inner signal

  type t =
    | Ident
    | Sin of Compound.t

  let compare sig1 sig2 =
    match sig1, sig2 with
    | Ident, Ident -> 0
    | Ident, Sin _ -> -1
    | Sin _, Ident -> 1
    | Sin sig1, Sin sig2 -> Compound.compare sig1 sig2
  let pp = Fmt.nop
end

module SigProd = Polynomial.Monomial.Make (Base)
