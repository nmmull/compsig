(lang dune 3.17)
(name compsig)
(generate_opam_files true)
(source (github nmmull/compsig))

(authors
 "Nathan Mull <nmmull@bu.edu>"
 "William Chen")

(maintainers "Nathan Mull <nmmull@bu.edu>")

(package
 (name compsig)
 (depends
   ocaml
   dune
   alcotest
   cmdliner
   menhir)
 (tags
  ("algebraic signal processing"
   "supercollider"
   "computer music")))

(using menhir 3.0)

(cram enable)