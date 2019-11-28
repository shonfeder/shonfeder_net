
.PHONY: deps
deps:
	dune build shonfeder_net.opam
	git add *.opam
	git commit -m "Update deps"
	opam install . --deps-only --with-test
