# Compsig

`compsig` is a tool for converting signal between different audio
programming languages (e.g.,
[supercollider](https://supercollider.github.io)).  This repository
contains an experiment/proof of concept towards such a tool (read:
it's incredibly rough).

We envisage `compsig` as a *[pandoc](https://pandoc.org) for signals*,
though in reality, it's inspired more by logical frameworks like
[Dedukti](https://deducteam.github.io).  In practical terms: we would
like to be able to port implementations of sythesizers across
different audio programming languages to expand the accessibility of
these tools for musicians and programmers.  In broader terms: we would
like to better understand the abstract structure of signals so that we
can give general, platform-independent, and extendible implementations
of synthesizers.

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
audio
synthesis](https://en.wikipedia.org/wiki/List_of_audio_programming_languages),
and their differences are not always superficial; some may be intended
for live performance, others better suited for noise music, others
for pedagogical use.

This is not terribly surprising; both music composition and
programming language design are creative endeavors.  Audio PL
designers are not only determining what PL paradigms to implement, but
also what inferface they want to expose to the composer/programmer (we
never want to stifle musical creativity by making the means of
composition too restrictive).

This poses a challenge to newcomers: learning a audio PL isn't just
learning new syntax; it may be learning a new framework for
composition.  And although these frameworks can be very similar, even
small differences in what kinds of operations are supported can be
sticking points in the learning process

A very simple example:
[`msynth`](https://github.com/smimram/monadic-synth) a (frankly, quite
beautiful) OCaml library for building synthesizers
[*monadically*](https://en.wikipedia.org/wiki/Monad_(functional_programming)
does not support by default the ability to parameterize sine
oscillators by a *phase shift*, a feature which is commonly used in
SuperCollider.  To be clear, it's not *impossible* create a sine
oscillator in `msynth` which takes a phase parameter, but doing so
requires having a deeper understanding of how the library works.

Despite all this, audio PLs are often built on the same fundamental
principles, e.g., time and signals.  And signals processing is a
well-established field with strong theoretical foundations.  Our goal
is to take advantage of this theory, to provide an *intermediate
abstract representation of signals* that can be used as a kind of
universal language to translate synthesizers implementions both to and
from existing audio PLs.

It is our belief that [algebraic signal
processing](https://ieeexplore.ieee.org/document/4520147) can form the
basis of such a conversion tool. The rough idea: signals can be
represented abstractly as element of a vector space (this basically
means signals can be added togethers and scaled). This picture can be
extended by introduces an algebra of filters which act of the vectors
space of signals (we have not implemented filters). Another way of
viewing this is as working in the free monadic structure which can be
derived from `msynth` (mentioned above).

The idea is simple on the surface:

* implement an interface for an abstract algebraic representation of signals
* for any given audio PL, implement a converter from the language to this algebraic representation, as well as a converter from the algebraic representation to the language
* To convert between any two audio PLs, convert from the first language to the signal algebra, and then from the signal algebra to the second language.

This ideas has other nice features, e.g., we don't need to convert to
another audio PL, but can instead pipe the abstract signal to a
visualization tool (e.g., [Matplotlib](https://matplotlib.org/)) so
that we can *see* the signal in whatever tool we'd like (we, for
example, have found Matplotlib to be better at visualizing signals
than SuperColliders built-in plotting tool).

## Methodology

The idea is not so simple in practice, there are quite a few technical
challenges and engineering problems to deal with.  Again, this project
is in it's very early stages. It's not really a tool at the moment,
it's more of a demonstration.

The most challenging problem from an engineering perspective (and
least interesting from a theoretical perspective) is building parsers
for existing fully-featured audio PLs. This can be done most
effectively by depending on general parsing frameworks like
[treesitter](https://tree-sitter.github.io/tree-sitter/). We have
chosen to ignore this problem for now and focus on

* the algebraic representation of signals
* the translation of this representation *into* existing audio PLs

To this end, we introduce a toy language we call *LambdaSC* (short for
lambda-super-collider) which is just gives us a way of writing
abstract signals more conveniently. The most important feature of this
language is that it takes *signal composition* as a primitive
operation.  The reason for this is two fold. First, we believe that
signal composition is a missing primitive in languages like
SuperCollider.  It can be effectively done in `msynth` using the
monadic bind operator (`>>=`), but even in this setting, it may not be
immediately clear to newcomers how this work. With this primitive, we
can easily *implement* oscillators with parameters of our choosing,
cutting down on the number of primitives we need. The second reason is
that we wanted our source language, despite not being full featured,
to have operations not necessarily supported by our target languages.
This better motivates the project.

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
