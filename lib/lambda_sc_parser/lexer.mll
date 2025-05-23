{
open Parser
}

let whitespace = [' ' '\t' '\n' '\r']+
let float = '-'? ['0'-'9']+ '.' ['0'-'9']*
let var = ['a'-'z' '_'] ['a'-'z' 'A'-'Z' '0'-'9' '_' '\'']*

rule read =
  parse
  | "signal" { SIGNAL }
  | ":" { COLON }
  | "fun" { FUN }
  | "->" { ARROW }
  | "let" { LET }
  | "=" { EQUALS }
  | "in" { IN }
  | "(" { LPAREN }
  | ")" { RPAREN }
  | "+" { PLUS }
  | "*" { TIMES }
  | "<<" { COMP }
  | "sin" { SIN }
  | "noise" { NOISE }
  | "triangle" { TRIANGLE }
  | "saw" { SAW }
  | "square" { SQUARE }
  | "t" { T }
  | float { FLOAT (float_of_string (Lexing.lexeme lexbuf)) }
  | var { VAR (Lexing.lexeme lexbuf) }
  | whitespace { read lexbuf }
  | eof { EOF }
