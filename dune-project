(lang dune 3.17)
(cram enable)
(name compsig)
(generate_opam_files true)

(source (github nmmull/compsig))

(authors
 "Nathan Mull <nmmull@bu.edu>"
 "William Chen")

(maintainers
 "Nathan Mull <nmmull@bu.edu>"
 "William Chen")

(license TODO)
(documentation TODO)

(package
 (name compsig)
 (synopsis "TODO")
 (description "TODO")
 (depends
   ocaml
   alcotest
   fmt
   cmdliner)
 (tags
  ("algebraic signal processing"
   supercollider
   "computer music")))

(using menhir 3.0)
