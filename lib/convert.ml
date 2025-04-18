open Syntax

module Matplotlib = struct
  let string_of_expr =
    let rec go = function
      | Ident -> "x"
      | Const f -> string_of_float f
<<<<<<< HEAD
      | Sin e -> "np.sin(" ^ go e^ ")"
      | Triangle _ -> assert false
      | Saw _ -> assert false
      | Square _ -> assert false
      | Noise _ -> assert false
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
=======
      | Sin e -> "np.sin(" ^ go e ^ ")"
      | Sum es ->
         List.fold_left
           (fun acc e -> acc ^ " + " ^ go e)
           "0.0"
           es
      | Prod es ->
         List.fold_left
           (fun acc e -> acc ^ " * " ^ go e)
           "1.0"
           es
>>>>>>> 878a36a2977cdcfe1e022a178aabd174ab46572a
    in go

  let of_signal (s : Signal.t) : string =
    let prog =
      String.concat "\n"
        [
          "import matplotlib.pyplot as plt";
          "import numpy as np";
          "x = np.linspace(0, 10, int(44100 * 10))"; (* TODO: Abstract over duration *)
          "y = " ^ string_of_expr (Signal.to_expr s);
          "fig, ax = plt.subplots()";
          "ax.plot(x, y)";
          "plt.show()";
        ]
    in prog
end

module Supercollider = struct
  let of_expr =
    let rec go = function
      | Ident -> "Line.ar(start: 0.0, end: 10.0, dur: 10.0)" (* TODO: Abstract over duration *)
      | Const f -> string_of_float f ^ "0"
      | Sin e ->
         let signal = Signal.of_expr e in
         let (freq, phase) = Signal.linearize signal in
         let freq = Signal.to_expr Signal.(mul (const (1. /. 2. /. Float.pi)) freq) in
         let phase = Signal.to_expr phase in
         String.concat ""
           [
             "SinOsc.ar(freq: ";
             go freq;
             ", phase: ";
             go phase;
             ")"
           ]
      | Sum es ->
            List.fold_left
              (fun acc e -> acc ^ " + " ^ go e)
              "0.0"
              es
      | Prod es ->
           List.fold_left
             (fun acc e -> acc ^ " * " ^ go e)
             "1.0"
             es
    in go

  let of_signal s =
    "s.waitForBoot({{" ^ of_expr (Signal.to_expr s) ^ "}.play;});"
end
