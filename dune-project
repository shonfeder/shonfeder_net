(lang dune 3.16)

(generate_opam_files true)

(name shonfeder_net)

(version 0.1.0)

(authors "Shon Feder")

(source
 (github shonfeder/shonfeder_net))

(maintainers "shon.feder@gmail.com")

(homepage "https://github.com/shonfeder/shonfeder_net")

(package
 (name shonfeder_net)
 (synopsis "TODO")
 (description "TODO")
 (depends
  (dune
   (>= 3.16))
  (ocaml
   (>= 5.2))
  (ocsigenserver
   (>= 6.0.0))
  (eliom
   (>= 11.0.1))
  (ocsipersist-dbm
   (>= 2.0.0))
  (tyxml
   (>= 4.3.0))
  (tyxml-ppx
   (>= 4.3.0))
  (cmarkit
   (>= 0.3))
  (logs
   (>= 0.7.0))
  (fpath
   (>= 0.7.2))
  (ppx_deriving
   (>= 4.4))))
