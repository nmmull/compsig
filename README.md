# Compsig

`compsig` is a tool for converting signal implementations between
programming languages for music composition and audio synthesis (e.g.,
[supercollider](https://supercollider.github.io)).  This repository
contains an experiment/proof of concept (read: it's incredibly rough).

Compsig is written in [OCaml](https://ocaml.org) by [William
Chen](https://github.com/chenxww) and [Nathan
Mull](https://nmmull.github.io) as a part of a
[UROP](https://www.bu.edu/urop/) project funded by Boston University.

## Usage

Currently, the only way to use `compsig` is to build it from source.
You can clone this program and build an executable using `dune build`.
You can run:

```
dune exec compsig -- --help
```

to see more details about using the tool.

## Synopsis



## LambdaSC

LambdaSC is a toy language for implementing signals with composition
as a primitive. It has the following grammar:

```
<op>  ::= + | * | <<
<sig> ::= sin | noise
        | triangle | saw | square
		| <float> | t
<e>   ::= let <v> = <e> in <e>
        | fun <v> -> <e> | <e>
	    | <e> <op> <e> | ( <e> )
	    | <v> | <sig>
```

For example, this is the program in `example/ex1.lsc`:

```ocaml
let pi = 3.14159265358979312 in
let sin_osc = fun freq phase ->
  sin << (2. * pi * freq * t + phase)
in
let s1 = sin_osc 440. 0. in
let s2 = sin_osc 1. 0. in
s2 * s1
```
