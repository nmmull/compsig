{
open Parser
}

let whitespace = [' ' '\t' '\n' '\r']+
let float = '-'? ['0'-'9']+ '.' ['0'-'9']+
let ident = ['a'-'z' '_'] ['a'-'z' 'A'-'Z' '0'-'9' '_' '\'']*

rule read =
  parse
  | "var" { VAR }
  | "=" { EQUALS }
  | ";" { SEMIC }
  | "," { COMMA }
  | "." { DOT }
  | "SinOsc" { SINOSC }
  | "ar" { AR }
  | "kr" { KR }
  | ":" { COLON }
  | "+" { PLUS }
  | "*" { TIMES }
  | "(" { LPAREN }
  | ")" { RPAREN }
  | float { FLOAT (float_of_string (Lexing.lexeme lexbuf)) }
  | ident { IDENT (Lexing.lexeme lexbuf) }
  | whitespace { read lexbuf }
  | eof { EOF }
