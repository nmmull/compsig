%{
open Syntax
%}

%token <float> FLOAT
%token <string> VAR
%token SIN "sin"
%token PLUS "+"
%token TIMES "*"
%token COMP "<<"
%token LET "let"
%token EQUALS "="
%token IN "in"
%token LPAREN "("
%token RPAREN ")"
%token T "t"
%token FUN "fun"
%token ARROW "->"
%token EOF

%left PLUS
%left TIMES
%left COMP

%start <Syntax.expr> prog

%%

prog:
  | e=expr EOF { e }

expr:
  | "let" x=VAR "=" e1=expr "in" e2=expr { App (Fun (x, e2), e1) }
  | "fun" xs=VAR+ "->" e=expr { List.fold_right (fun x e -> Fun(x, e)) xs e }
  | e=expr1 { e }

%inline bop:
  | "+" { Add }
  | "*" { Mul }
  | "<<" { Comp }

expr1:
  | e1=expr1 op=bop e2=expr1 { Bop(op, e1, e2) }
  | es=expr2+ { List.(fold_left (fun e1 e2 -> App (e1, e2)) (hd es) (tl es)) }

expr2:
  | n=FLOAT { Float n }
  | "sin" { Sin }
  | "t" { Ident }
  | x=VAR { Var x }
  | "(" e=expr ")" { e }
