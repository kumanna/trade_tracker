all: _build/default/bin/main.exe _build/default/bin/populate_brokerage.exe _build/default/bin/update_holdings.exe _build/default/bin/capgain_report.exe

COMMON_DEPS = bin/db_wrapper.ml \
bin/db_wrapper.mli \
bin/main.ml \
bin/transaction.ml \
bin/transaction.mli

_build/default/bin/main.exe: bin/main.ml $(COMMON_DEPS)
	dune build bin/main.exe

_build/default/bin/populate_brokerage.exe: bin/populate_brokerage.ml $(COMMON_DEPS)
	dune build bin/populate_brokerage.exe

_build/default/bin/update_holdings.exe: bin/update_holdings.ml $(COMMON_DEPS)
	dune build bin/update_holdings.exe

_build/default/bin/capgain_report.exe: bin/capgain_report.ml $(COMMON_DEPS)
	dune build bin/capgain_report.exe

.PHONY: clean exec examplerun
clean:
	dune clean

examplerun: example2.csv.txt example.csv.txt
	$(RM) example.db
	dune exec bin/main.exe example.db example.csv.txt
	dune exec bin/populate_brokerage.exe example.db 0.1 20 18
	dune exec bin/update_holdings.exe example.db
	dune exec bin/main.exe example.db example2.csv.txt
	dune exec bin/populate_brokerage.exe example.db 0.1 20 18
	dune exec bin/update_holdings.exe example.db
	dune exec bin/capgain_report.exe example.db
	dune exec bin/capgain_report.exe example.db 2023
