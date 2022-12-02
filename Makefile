files := $(wildcard src/*.m)
headers := $(wildcard src/*.h)

bin/build: $(files) $(headers)
	mkdir -p bin
	clang $(files) `cat compile_flags.txt` `objfw-config --all` -save-temps=obj -o bin/build
	@echo

clean:
	rm -rf bin/

run: bin/build
	@bin/build

.PHONY: clean run