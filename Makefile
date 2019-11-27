
.PHONY: deps
deps:
	dune build shonfeder_net.opam
	opam install . --deps-only --with-test
