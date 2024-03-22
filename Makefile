all: _build/default/bin/main.exe

_build/default/bin/main.exe: bin/*.ml bin/*.mli
	dune build bin/main.exe

.PHONY: clean exec
clean:
	dune clean

exec: _build/default/bin/main.exe
	dune exec bin/main.exe
