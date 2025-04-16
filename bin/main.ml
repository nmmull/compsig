open Compsig
open Cmdliner


(*
type conversion_info = 
    {
        input_type : supported_file_types;
        output_type : supported_file_types;
    }
*)


let compsig_func f_in f_out = 
    let input = match f_in with
        | "sc" -> SuperCollider
        | "lsc" -> LambdaSC
        | "py" -> Matplotlib
        | _ -> failwith "Invalid file type"
    in
    let output = match f_out with
        | "sc" -> SuperCollider
        | "lsc" -> LambdaSC
        | "py" -> Matplotlib
        | _ -> failwith "Invalid file type"
    in
    let standin = In_channel.(input_all stdin) in
    print_string (convert input output standin)

let file_in =
    let doc = "The filetype of the input." in
    Arg.(value (opt string "empty filename" (info ["i"; "input"] ~doc ~docv:"FILE_IN")))

let file_out =
    let doc = "The filetype of the output." in
    Arg.(value (opt string "empty filename" (info ["o"; "output"] ~doc ~docv:"FILE_OUT")))

let compsig_t = Term.(const compsig_func $ file_in $ file_out)

let compsig_cmd =
    let doc = "Port representations of signals between different languages." in
    let man = [] in
    let info = Cmd.info "Compsig" ~version:"0.1" ~doc ~man in
    Cmd.v info compsig_t

let main () = exit (Cmd.eval compsig_cmd)

let () = main ()
(*
let superscript num = print_endline (int_to_exponent num)

let number =
    let doc = "The number to superscript." in
    Arg.(value (opt int 0 (info ["s"; "superscript"] ~doc ~docv:"SUPERSCRIPT")))

let superscript_t = Term.(const superscript $ number)

let superscript_cmd =
    let doc = "Print the superscript of a number" in
    let man = [
        `S Manpage.s_bugs;
        `P "I'on't know what you're talking about."]
    in
    let info = Cmd.info "superscript" ~version:"0.1" ~doc ~man in
    Cmd.v info superscript_t

let main () = exit (Cmd.eval superscript_cmd)
*)