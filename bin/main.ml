open Compsig.Utils
open Cmdliner

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
let () = main ()