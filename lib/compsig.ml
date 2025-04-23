module Utils = Utils
module Monomial = Monomial
module Polynomial = Polynomial
module Signal = Signal
module Convert = Convert
module Lambda_sc = Lambda_sc

let ver_num = "0.1"

exception UnsupportedInputType
exception UnsupportedOutputType

let convert in_format out_format str =
  if in_format = out_format
  then str
  else
    let signal =
      match in_format with
      | `LambdaSC -> (
        match
          Option.map
            Lambda_sc.eval
            (Lambda_sc.parse str) with
        | Some signal -> signal
        | _ -> failwith "Invalid source signal"
      )
      | _ -> raise UnsupportedInputType
    in
    match out_format with
    | `Matplotlib -> Convert.Matplotlib.of_signal signal
    | `SuperCollider -> Convert.SuperCollider.of_signal signal
    | _ -> raise UnsupportedOutputType
