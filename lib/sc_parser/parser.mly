%{
open Syntax

let split_last =
  let rec go acc = function
  | [] -> None
  | [x] -> Some (List.rev acc, x)
  | x :: l -> go (x :: acc) l
%}

%token VAR "var"
%token <string> IDENT
%token <string> LABEL
%token EQUALS "="
%token SEMIC ";"
%token DOT "."

%token SINOSC "SinOsc"
%token FREQ "freq"
%token PHASE "phase"
%token MUL "mul"
%token ADD "add"

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
  | "var"? x=ident "=" e=expr { Assign (x, e) }
  | e=expr { Expr e }

semi_stmt:
  | ";" s=stmt { s }

stmts:
  | s=stmt ss=semi_stmt* ?";" { s :: ss }

ar:
  | "ar" { () }
  | "kr" { () }

arg_label:
  | label=LABEL ":" { label }

arg:
  | label=arg_label? e=expr { (label, expr) }

comma_arg:
  | "," arg=arg { arg }

args:
  | a=arg, as=comma_args* ","? { a :: as }

%inline bop:
  | "+" { Add }
  | "*" { Mul }

expr:
  | "SinOsc" "." ar "(" args ")" { assert false }
  | e1=expr op=bop e2=expr { Bop(op, e1, e2) }
  | n=FLOAT { Float n }
  | x=VAR { Var x }
  | "(" e=expr ")" { e }
