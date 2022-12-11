files := $(wildcard src/*.m)
headers := $(wildcard src/*.h)

bin/build: $(files) $(headers)
	mkdir -p bin
	clang $(files) -g -O3 `cat compile_flags.txt` `objfw-config --all` -save-temps=obj -o bin/build
	@echo

.PHONY: clean
clean:
	rm -rf bin/

.PHONY: run
run: bin/build
	@bin/build

.PHONY: profile
profile: bin/build
	valgrind --tool=callgrind --callgrind-out-file=/tmp/callgrind.out bin/build
	python -m gprof2dot -f callgrind /tmp/callgrind.out | dot -Tsvg -o profile.svg