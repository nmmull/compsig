open Syntax

module Matplotlib = struct
  let string_of_expr =
    let rec go = function
      | Ident -> "x"
      | Noise -> "np.random.uniform(-1, 1, x.shape)"
      | Const f -> string_of_float f
      | Sin e -> "np.sin(" ^ go e ^ ")"
      | Triangle e -> "sp.sawtooth(" ^ go e ^ ", 0.5)"
      | Saw e -> "sp.sawtooth(" ^ go e ^ ")"
      | Square e -> "sp.square(" ^ go e ^ ")"
      | Sum es ->
        es
        |> List.map go
        |> List.filter ((<>) "0.0")
        |> (fun l -> if List.is_empty l then ["0.0"] else l)
        |> String.concat " + "
      | Prod es ->
        es
        |> List.map go
        |> List.filter ((<>) "1.0")
        |> (fun l -> if List.is_empty l then ["1.0"] else l)
        |> String.concat " * "
    in go

  let of_signal (s : Signal.t) : string =
    let prog =
      String.concat "\n"
        [
          "import matplotlib.pyplot as plt";
          "import numpy as np";
          "import scipy.signal as sp";
          "x = np.linspace(0, 10, int(44100 * 10))"; (* TODO: Abstract over duration *)
          "y = " ^ string_of_expr (Signal.to_expr s);
          "fig, ax = plt.subplots()";
          "ax.plot(x, y)";
          "plt.show()";
        ]
    in prog
end

module SuperCollider = struct
  let of_expr =
    let extract e =
      let signal = Signal.of_expr e in
      let (freq, phase) = Signal.linearize signal in
      ( Signal.to_expr Signal.(mul (const (1. /. 2. /. Float.pi)) freq)
      , Signal.to_expr phase
      )
    in
    let rec go = function
      | Ident -> "Line.ar(start: 0.0, end: 10.0, dur: 10.0)" (* TODO: Abstract over duration *)
      | Const f -> string_of_float f ^ "0"
      | Noise -> "WhiteNoise.ar()"
      | Sin e ->
        let freq, phase = extract e in
        String.concat ""
          [
            "SinOsc.ar(freq: ";
            go freq;
            ", phase: ";
            go phase;
            ")"
          ]
      | Triangle e ->
        let freq, phase = extract e in
        String.concat ""
          [
            "LFTri.ar(freq: ";
            go freq;
            ", iphase: ";
            go phase;
            ")"
          ]
      | Saw e ->
        let freq, phase = extract e in
        String.concat ""
          [
            "LFSaw.ar(freq: ";
            go freq;
            ", iphase: ";
            go phase;
            ")"
          ]
      | Square e ->
        let freq, phase = extract e in
        String.concat ""
          [
            "LFPulse.ar(freq: ";
            go freq;
            ", iphase: ";
            go phase;
            ")"
          ]
      | Sum es ->
        es
        |> List.map (fun x -> "(" ^ go x ^ ")")
        |> List.filter ((<>) "0.0")
        |> (fun l -> if List.is_empty l then ["0.0"] else l)
        |> String.concat " + "
      | Prod es ->
        es
        |> List.map go
        |> List.filter ((<>) "1.0")
        |> (fun l -> if List.is_empty l then ["1.0"] else l)
        |> String.concat " * "
    in go

  let of_signal s =
    "s.waitForBoot({{var out = " ^ of_expr (Signal.to_expr s) ^ "; [out, out]}.play;});"
end
