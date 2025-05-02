%{
open Syntax
%}

%token <float> FLOAT
%token <string> VAR
%token SIN "sin"
%token NOISE "noise"
%token TRIANGLE "triangle"
%token SAW "saw"
%token SQUARE "square"
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
%token COLON ":"
%token SIGNAL "signal"
%token EOF

%left PLUS
%left TIMES
%left COMP
%right ARROW

%start <Syntax.expr> prog

%%

prog:
  | e=expr EOF { e }

ty:
  | "signal" { SignalTy }
  | t1=ty "->" t2=ty { FunTy (t1, t2) }
  | "(" ty=ty ")" { ty }



arg:
  | x=VAR { (x, SignalTy) }
  | "(" x=VAR ":" ty=ty ")" { (x, ty) }

expr:
  | "let" x=VAR "=" e1=expr "in" e2=expr { Let (x, e1, e2) }
  | "fun" xs=arg+ "->" e=expr { List.fold_right (fun (x, ty) e -> Fun(x, ty, e)) xs e }
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
  | "noise" { Noise }
  | "triangle" { Triangle }
  | "saw" { Saw }
  | "square" { Square }
  | "t" { Ident }
  | x=VAR { Var x }
  | "(" e=expr ")" { e }
