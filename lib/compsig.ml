module Utils = Utils
module Monomial = Monomial
module Polynomial = Polynomial
module Signal = Signal
module Convert = Convert
module Lambda_sc = Lambda_sc
module Supercollider = Supercollider

let ver_num = "0.1"

exception UnsupportedInputType
exception UnsupportedOutputType

let convert in_format out_format str =
  if in_format = out_format
  then str
  else
    let signal =
      match in_format with
      | `LambdaSC -> Lambda_sc.interp str
      | _ -> raise UnsupportedInputType
    in
    match out_format with
    | `Matplotlib -> Convert.Matplotlib.of_signal signal
    | `SuperCollider -> Convert.SuperCollider.of_signal signal
    | _ -> raise UnsupportedOutputType
