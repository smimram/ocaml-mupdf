all:
	$(MAKE) -C src $@

test:
	@dune runtest

.PHONY: test
