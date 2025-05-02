%{
open Syntax

let split_last =
  let rec go acc = function
    | [] -> None
    | [x] -> Some (List.rev acc, x)
    | x :: l -> go (x :: acc) l
  in go []
%}

%token VAR "var"
%token <float> FLOAT
%token <string> IDENT
%token EQUALS "="
%token SEMIC ";"
%token COMMA ","
%token DOT "."

%token SINOSC "SinOsc"
%token AR "ar"
%token KR "kr"

%token COLON ":"

%token PLUS "+"
%token TIMES "*"
%token LPAREN "("
%token RPAREN ")"
%token EOF

%left PLUS
%left TIMES

%start <Syntax.expr> prog

%%

prog:
  | s=stmts EOF
    {
      match split_last s with
      | None -> Float 0.
      | Some (s, Expr e) -> Block (s, e)
      | Some (s, Assign (_, e)) -> Block (s, e)
    }

stmt:
  | x=IDENT "=" e=expr { Assign (x, e) }
  | "var" x=IDENT "=" e=expr { Assign (x, e) }
  | e=expr { Expr e }

/* https://discuss.ocaml.org/t/solving-shift-reduce-conflicts-for-optional-trailing-comma-in-menhir/15042 */
stmts:
  | s=stmt { [s] }
  | s=stmt ";" { [s] }
  | s=stmt ";" ss=separated_nonempty_list(SEMIC, stmt) { s :: ss }

ar:
  | "ar" { () }
  | "kr" { () }

arg_label:
  | label=IDENT ":" { label }

arg:
  | label=arg_label expr=expr { (Some label, expr) }
  | expr=expr { (None, expr) }

args:
  | args=separated_list(COMMA, arg) { args }

%inline bop:
  | "+" { Add }
  | "*" { Mul }

expr:
  | "SinOsc" "." ar "(" args ")" { SinOsc [] }
  | e1=expr op=bop e2=expr { Bop(op, e1, e2) }
  | n=FLOAT { Float n }
  | x=IDENT { Var x }
  | "(" e=expr ")" { e }
