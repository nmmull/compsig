include Sc_parser.Syntax

let parse s =
  let open Sc_parser in
  match Parser.prog Lexer.read (Lexing.from_string s) with
  | expr -> Some expr
  | exception _ -> None
