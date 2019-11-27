(lang dune 1.11)
(generate_opam_files true)

(name shonfeder_net)
(version 0.1.0)

(authors "Shon Feder")
; (license MIT)
; (source (github shonfeder/alg_structs))
(maintainers "shon.feder@gmail.com")
; (homepage "https://github.com/shonfeder/alg_structs")
; (bug_reports "https://github.com/shonfeder/alg_structs/issues")
; (documentation "https://shonfeder.github.io/alg_structs/")

(package
 (name shonfeder_net)
 (synopsis "TODO")
 (description "TODO")
 (depends
  (dune (and (>= 1.11.4) (< 2.0.0)))

  (ocaml (>= 4.08.0))
  ;; inc to v13 once opium can support
  (core_kernel (and (>= v0.12.0) (< v0.13.0)))
  (markdown (>= 0.2.1))
  (tyxml (>= 4.3.0))

  ; (js_of_ocaml (>= 3.4.0))
  ; (js_of_ocaml-ppx (>= 3.4.0))
  ; (js_of_ocaml-ppx_deriving.std_json (>= 3.4.0))
  ; (js_of_ocaml-lwt (>= 3.4.0))

  (opium (>= 0.17.1))

  (ppx_deriving (>= 4.4))

  ; (qcheck (>= 0.12))
  ; (qcheck-alcotest (>= 0.12))
))
