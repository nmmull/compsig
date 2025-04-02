%{
open Lambda_sc_intf
%}

%token <float> FLOAT
%token <int> INT
%token <string> VAR
%token SIN "sin"
%token POW "pow"
%token PLUS "+"
%token TIMES "*"
%token COMP "<<"
%token LET "let"
%token EQUALS "="
%token IN "in"
%token LPAREN "("
%token RPAREN ")"
%token COMMA ","
%token T "t"
%token EOF

%left PLUS
%left TIMES
%left COMP

%start <Lambda_sc_intf.expr> prog

%%

prog:
  | e=expr EOF { e }

expr:
  | "let" x=VAR "=" e1=expr "in" e2=expr { Let (x, e1, e2) }
  | e=expr1 { e }

%inline bop:
  | "+" { Add }
  | "*" { Mul }
  | "<<" { Comp }

expr1:
  | e1=expr1 op=bop e2=expr1 { Bop(op, e1, e2) }
  | "sin" "(" e1=expr2 "," e2=expr2 ")" { Sin {freq=e1;phase=e2} }
  | e=expr2 { e }

expr2:
  | n=FLOAT { Float n }
  | "t" { Ident }
  | x=VAR { Var x }
  | "pow" "(" e=expr1 "," n=INT ")" { Pow(e, n) }
  | "(" e=expr ")" { e }
