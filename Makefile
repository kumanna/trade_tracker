all: _build/default/bin/main.exe _build/default/bin/populate_brokerage.exe

COMMON_DEPS = bin/db_wrapper.ml \
bin/db_wrapper.mli \
bin/main.ml \
bin/transaction.ml \
bin/transaction.mli

_build/default/bin/main.exe: bin/main.ml $(COMMON_DEPS)
	dune build bin/main.exe
_build/default/bin/populate_brokerage.exe: bin/populate_brokerage.ml $(COMMON_DEPS)
	dune build bin/populate_brokerage.exe

.PHONY: clean exec
clean:
	dune clean

exec: _build/default/bin/main.exe
	dune exec bin/main.exe
