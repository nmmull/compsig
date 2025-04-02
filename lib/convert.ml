open Syntax

module Matplotlib = struct
  let string_of_expr =
    let rec go = function
      | Ident -> "x"
      | Const f -> string_of_float f
      | Sin e -> "np.sin(" ^ go e ^ ")"
      | Sum es -> (
         match es with
         | [] -> ""
         | e :: es ->
            List.fold_left
              (fun acc e -> acc ^ " + " ^ go e)
              (go e)
              es
      )
      | Prod es -> (
         match es with
         | [] -> ""
         | e :: es ->
            List.fold_left
              (fun acc e -> acc ^ " * " ^ go e)
              (go e)
              es
      )
      | Pow (e, n) ->
         let e = go e in
         if n = 1
         then e
         else e ^ " ** " ^ string_of_int n
    in go

  let of_signal (s : Signal.t) : string =
    let prog =
      String.concat "\n"
        [
          "import matplotlib.pyplot as plt";
          "import numpy as np";
          "x = np.linspace(0, 10, 100)";
          "y = " ^ string_of_expr (Signal.to_expr s);
          "fig, ax = plt.subplots()";
          "ax.plot(x, y)";
          "plt.show()";
        ]
    in prog
end

module Supercollider = struct
  let string_of_expr =
    let go _ = assert false
  in go
end
