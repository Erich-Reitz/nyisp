SRC_FILES = $(shell find src -name "*.nim")

compile:
	mkdir -p bin
	nim c --out:yisp  --outdir:bin --styleCheck:error   src/main.nim

format:
	nimpretty $(SRC_FILES)

clean:
	rm -rf bin/*
