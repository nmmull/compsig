open Cmdliner

let in_formats =
  [
    "lsc", `LambdaSC;
  ]

let out_formats =
  [
    "lsc", `LambdaSC;
    "sc", `SuperCollider;
    "py", `Matplotlib;
  ]

let in_format_t =
  let doc = "The filetype of the input. See TODO for supported formats." in
  Arg.(value (opt (enum in_formats) `LambdaSC (info ["i"; "input"] ~doc)))

let out_format_t =
  let doc = "The filetype of the output. See TODO for supported formats." in
  Arg.(value (opt (enum out_formats) `Matplotlib (info ["o"; "output"] ~doc)))

let convert in_format out_format =
  In_channel.(input_all stdin)
  |> Compsig.convert in_format out_format
  |> print_string

let compsig_t = Term.(const convert $ in_format_t $ out_format_t)

let compsig_cmd =
  let doc = "signal converter" in
  let info = Cmd.info "Compsig" ~version:Compsig.ver_num ~doc in
  Cmd.v info compsig_t

let main () = exit (Cmd.eval compsig_cmd)
let () = main ()
