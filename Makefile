all:
	$(MAKE) -C src $@

test:
	@dune runtest

doc:
	@dune build @doc

.PHONY: test doc
