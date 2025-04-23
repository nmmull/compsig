module Utils = Utils
module Monomial = Monomial
module Polynomial = Polynomial
module Signal = Signal
module Convert = Convert
module Lambda_sc = Lambda_sc

type format =
  | LambdaSC
  | Supercollider
  | Matplotlib

let convert in_format out_format str =
  if in_format = out_format
  then str
  else
    let signal =
      match in_format with
      | LambdaSC -> Lambda_sc.interp str
      | _ -> failwith "Not implemented"
    in
    match out_format with
    | Matplotlib -> Convert.Matplotlib.of_signal signal
    | Supercollider -> Convert.Supercollider.of_signal signal
    | _ -> failwith "Not implemented"
