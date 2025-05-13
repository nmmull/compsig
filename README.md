# Compsig

`compsig` is a tool for converting signals between different audio
programming languages.  This repository contains an experiment/proof
of concept/demonstration of such a tool (read: it's incredibly
rough).

We envisage `compsig` as a *[pandoc](https://pandoc.org) for signals*
(in reality, it's inspired more by logical frameworks like
[Dedukti](https://deducteam.github.io)).  In practical terms: we would
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
build`, or you can use `dune exec`, e.g.,

```
$ dune exec compsig -- --help
```

opens a `man` page for `compsig`.

## Pitch

There are [quite a few programming languages for music composition and
audio
synthesis](https://en.wikipedia.org/wiki/List_of_audio_programming_languages),
and their differences aren't necessarily superficial; some are
intended for live performance, others better suited for noise music,
others for pedagogical use.

This is not terribly surprising; both music composition and
programming language design are creative endeavors.  Audio PL
designers not only have to determine what PL paradigms they want in
their language, but also what inferface they want to expose to the
composer/programmer (we never want to stifle musical creativity by
making the means of composition too restrictive).

This poses a challenge to newcomers: learning a audio PL isn't just
learning new syntax; it may be learning a new framework for
composition.  And although these frameworks can be very similar, even
small differences in what kinds of operations are supported can be
sticking points in the learning process.

A very simple example:
[`msynth`](https://github.com/smimram/monadic-synth) a (frankly, quite
beautiful) OCaml library for building synthesizers
[*monadically*](https://en.wikipedia.org/wiki/Monad_(functional_programming))
doesn't support by default sine oscillators with a *phase shift*
parameter. Sine oscillators in
[SuperCollider](https://supercollider.github.io/) have a phase
parameter, and this feature is used to create singals with surprising
structure and timbre (e.g., see the example below).  To be clear, it's
not *impossible* to create a sine oscillator in `msynth` which takes a
phase parameter, but doing so requires having a deeper understanding
of how the library works.

Despite all this, audio PLs are built on the same fundamental
principles, e.g., time and signals.  And signals processing in general
is a well-established field with strong theoretical foundations.  Our
goal is to take greater advantage of this theory, to provide an
*intermediate abstract representation of signals* that can be used as
a kind of universal language to translate synthesizers implementions
both to and from existing audio PLs.

We believe that [algebraic signal
processing](https://ieeexplore.ieee.org/document/4520147) can form the
basis of a conversion tool like `compsig`. The rough idea: signals can
be represented abstractly as element of a ring (this basically means
signals can be pointwise added and multiplied together). This picture
can be extended by introduces an algebra of filters which acts on the
ring of signals (note: we have not implemented filters). Another way
of viewing this is as working in a free monadic structure which can be
derived from something like `msynth`.

So the idea of `compsig` is simple in theory:

* We implement an interface for an abstract algebraic representation of signals. In this basic experiment we choose to represent signals as polynomials of single-argument uninterpreted functions, one for each signal kind (side note: this is a very nice example of recursive modules since the uninterpreted functions representing signals can have these polynomials of uninterpreted functions as arguments). This can be seen in the definition of `Signal.t`.
* For any audio PL, we can implement a converter from the language to this algebraic representation, as well as a converter from the algebraic representation to the language. To convert between any two audio PLs, we can convert from the first
language to the signal algebra, and then from the signal algebra to
the second language.

This idea has other surprisingly nice features. We don't *need* to
convert between audio PLs, but can instead translate an abstract
signal into something which can be visualized, e.g., using
[Matplotlib](https://matplotlib.org/)). This allows us to better *see*
the signal we design (note: we've found Matplotlib to be better for
visualizing signals than SuperColliders built-in plotting tool).  It's
also worth noting that this abstract representation means that we
don't need to worry about the low-level details of audio synthesis
until we've translated to a target language.

## Methodology

The idea is not as simple in practice.  The most challenging problem
from an engineering perspective (and least interesting from a
theoretical perspective) is building parsers for existing
fully featured audio PLs. This can be done most effectively by
depending on general parsing frameworks like
[treesitter](https://tree-sitter.github.io/tree-sitter/). We've
chosen to ignore this problem for now and focus on

* the algebraic representation of signals
* the translation of this representation *into* existing audio PLs

## LambdaSC

To this end, we introduce a toy language we call *lambdaSC* (short for
lambda-SuperCollider) which is gives us a way of writing abstract
signals more conveniently. The most important feature of this language
is that it takes *signal composition* as a primitive operation.  The
reason for this is two fold. First, we believe that signal composition
is a missing primitive in languages like SuperCollider.  It can be
effectively done in `msynth` using the monadic bind operator (`>>=`),
but even in this setting, it may not be immediately clear to newcomers
how this works. With this primitive, we can easily *implement*
oscillators with parameters of our choosing, cutting down on the
number of primitives we need. The second reason is that we wanted our
source language, despite not being fully featured, to have operations
not necessarily supported by our target languages.

LambdaSC has the following grammar:

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

This, for example, is a simple lambdaSC program (which appears in
`example/ex1.lsc`).

```ocaml
let pi = 3.14159265358979312 in
let sin_osc = fun freq phase ->
  sin << (2. * pi * freq * t + phase)
in
let s1 = sin_osc 440. 0. in
let s2 = sin_osc 1. 0. in
s2 * s1
```

Note that there is no built-in function for constructing a sine wave
of a given frequency and phase.  This function can be implemented by
composing `sin` with a linear function of `t`, the identity (time)
signal.

LambdaSC programs are intepreted as `Signal.t` values, as described
above.

## Example

Consider this more complicated example, which is a translation of
tweet0045 by [Fredrik Olofsson](https://fredrikolofsson.com/) (and appears in `examples/ex4.ml`).

```ocaml
let pi = 3.14159265358979312 in
let sin_osc = fun freq phase -> sin << (2. * pi * freq * t + phase) in
let s1 = sin_osc (sin_osc 0.11 0.) 0. in
let s2 = 95. * sin_osc 0.01 0. + 1. in
let s3 = 60. * sin_osc 0.005 0. in
let s4 = s3 * sin_osc s2 0. + 100. in
let s5 = sin_osc 98. 0. + sin_osc 97. 0. in
let s6 = pi + sin_osc 0.0005 0. in
let s7 = s6 * sin_osc s4 s5 in
sin_osc s1 s7
```

If we want to hear this piece, we can translate into a supercollider
script and play it using `sclang`:

```
$ dune exec compsig -- -i lsc -o sc < examples/ex4.ml > out.scd
$ sclang out.scd
```

If we want to *see* this piece, we can translate it into a python script and pipe it into `python3`

```
$ dune exec compsig -- -i lsc -o py < examples/ex4.ml | python3
```

Note that the output script depends on Matplotlib and
[SciPy](https://scipy.org/). If successful, you should see a plot like
this one.

![image](example/ex4.png)

## Future Work

There is still quite a bit to do on this project. Of course, we'd like
to make this usable tool, but before doing this, we have a couple
things left to experiment with:

* implementing filters
* attempting less destructive translations, i.e., maintaining more of the original structure of the program when possible
* dealing with the "time" component of audio PLs, which is more important to music composition in general
* looking more deeply into other audio PLs
