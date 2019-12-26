(lang dune 1.11)
(generate_opam_files true)

(name shonfeder_net)
(version 0.1.0)

(authors "Shon Feder")
(source (github shonfeder/shonfeder_net))
(maintainers "shon.feder@gmail.com")
(homepage "https://github.com/shonfeder/shonfeder_net")

(package
 (name shonfeder_net)
 (synopsis "TODO")
 (description "TODO")
 (depends
  (dune (and (>= 1.11.4) (< 2.0.0)))

  (ocaml (>= 4.08.0))
  ;; inc to v13 once opium can support
  (core_kernel (and (>= v0.12.0) (< v0.13.0)))

  (opium (>= 0.17.1))
  (omd (>= 1.3.1))
  (tyxml (>= 4.3.0))
  (tyxml-ppx (>= 4.3.0))
  (logs (>= 0.7.0))
  (fpath (>= 0.7.2))


  (ppx_deriving (>= 4.4))
))
