all: _build/default/bin/main.exe _build/default/bin/populate_brokerage.exe _build/default/bin/update_holdings.exe

COMMON_DEPS = bin/db_wrapper.ml \
bin/db_wrapper.mli \
bin/main.ml \
bin/transaction.ml \
bin/transaction.mli

_build/default/bin/main.exe: bin/main.ml $(COMMON_DEPS)
	dune build bin/main.exe

_build/default/bin/populate_brokerage.exe: bin/populate_brokerage.ml $(COMMON_DEPS)
	dune build bin/populate_brokerage.exe

_build/default/bin/update_holdings.exe: bin/populate_brokerage.ml $(COMMON_DEPS)
	dune build bin/update_holdings.exe

.PHONY: clean exec test
clean:
	dune clean

test: input.csv
	$(RM) stockdata.db
	dune exec bin/main.exe stockdata.db input.csv
	dune exec bin/populate_brokerage.exe stockdata.db 0.1 20 18
