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

We envisage the `compsig` project as an attempt to create a
*[pandoc](https://pandoc.org) for signals*. In reality, the
inspiration comes more from logical frameworks like
[Dedukti](https://deducteam.github.io).

There are quite a few programming languages for music composition

## LambdaSC

LambdaSC is a toy language for implementing signals with composition
as a primitive. It has the following grammar:

```
<op>  ::= + | * | <<
<sig> ::= sin | noise
        | triangle | saw | square
        | <float> | t
<vs>  ::= <v> | <v> <vs>
<e>   ::= let <v> = <e> in <e>
        | fun <vs> -> <e> | <e>
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

In particular, note that there is no built-in function for
constructing a sine wave of a given frequency and phase.  This
function can be implemented by composing `sin` with a linear function
of `t`, the identity (raw time) signal.

LambdaSC programs are evaluated to `Signal.t` values, which are
essentially polynomials of single-argument uninterpreted functions,
one for each signal kind (side note: this is a very nice example of
[recursive modules](https://ocaml.org/manual/4.11/manual024.html)
since the uninterpreted functions representing signals can have these
polynomials of uninterpreted functions as arguments).
