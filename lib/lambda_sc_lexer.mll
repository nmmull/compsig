{
open Lambda_sc_parser
}

let whitespace = [' ' '\t' '\n' '\r']+
let float = '-'? ['0'-'9']+ '.' ['0'-'9']*
let int = '-'? ['0'-'9']+
let var = ['a'-'z' '_'] ['a'-'z' 'A'-'Z' '0'-'9' '_' '\'']*

rule read =
  parse
  | "let" { LET }
  | "=" { EQUALS }
  | "in" { IN }
  | "(" { LPAREN }
  | ")" { RPAREN }
  | "," { COMMA }
  | "+" { PLUS }
  | "*" { TIMES }
  | "<<" { COMP }
  | "Sin" { SIN }
  | "Pow" { POW }
  | "T" { T }
  | float { FLOAT (float_of_string (Lexing.lexeme lexbuf)) }
  | int { INT (int_of_string (Lexing.lexeme lexbuf)) }
  | var { VAR (Lexing.lexeme lexbuf) }
  | whitespace { read lexbuf }
  | eof { EOF }
