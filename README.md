# Compsig

`compsig` is a tool for converting signal between programming
languages for music composition and audio synthesis (e.g.,
[supercollider](https://supercollider.github.io)).  This repository
contains an experiment/proof of concept towards such a tool (read:
it's incredibly rough).

We envisage `compsig` as a *[pandoc](https://pandoc.org) for signals*,
though in reality, it's inspired more by logical frameworks like
[Dedukti](https://deducteam.github.io).  In practical terms: we would
like to be able to port implementations of sythesizers across
different audio programming languages to expand the accessibility of
these tools for musicians and computer scientists.  In broader terms:
we would like to better understand the abstract structure of signals
so that we can give general and extendible implementations of
synthesizers.

Compsig is written in [OCaml](https://ocaml.org) by [William
Chen](https://github.com/chenxww) and [Nathan
Mull](https://nmmull.github.io) as a part of a
[UROP](https://www.bu.edu/urop/) project funded by Boston University.

## Usage

Currently, the only way to use `compsig` is to build it from source.
You can clone this repository and build an executable using `dune
build`.  You can run:

```
dune exec compsig -- --help
```

to see more details about using the tool.  Also take a look at the
example below.

## Pitch

There are [quite a few programming languages for music composition and
signal
design](https://en.wikipedia.org/wiki/List_of_audio_programming_languages). Part
of the reason for this breadth of options is that music is a
subjective field, and there are several ways of presenting an
interface to a composer.  And the motives of these languages can often
be quite different; some may be intended for live performance, others
are better suited for concrete music, and others still for pedagogical
use. So even ignoring of the different syntax of each language, they
often also have different interfaces or different levels of support
for various operations.

For a very simple example,
[`msynth`](https://github.com/smimram/monadic-synth) a OCaml library
for building synthesizers based on the principles of
[monads](https://en.wikipedia.org/wiki/Monad_(functional_programming)
does not support by default the ability to parameterize sine waves by
a *phase shift*, a feature which is commonly used in SuperCollider.
To be clear, it's not *impossible* create a sine oscillator in `msynth`
which takes a phase parameter, but this requires having a deeper
understanding of how the library works.



Despite the wide range of audio programming languages, signals
processing is a well-established field with strong theoretical
foundations.  And it is our belief that [algebraic signal
processing](https://ieeexplore.ieee.org/document/4520147) can form the
basis of a conversion tool for signals.

## Methodology

### LambdaSC

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
