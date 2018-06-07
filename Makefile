NAME := pomodoro
BINDIR := release
BIN := $(BINDIR)/$(NAME)

GOX_OSARCH := darwin/amd64 linux/amd64
VERSION := 0.1.0

LDFLAGS := "-X main.Version=$(VERSION)" 

default: deps test build

test: deps
	go test ./...

install: build
	cp $(BIN) /usr/local/bin/$(NAME)

build: $(BIN)

clean:
	rm -rf $(BINDIR)

$(BIN): deps
	go build -ldflags $(LDFLAGS) -o $@

release: deps
	gox \
	  -ldflags $(LDFLAGS) -osarch="$(GOX_OSARCH)" \
	  -output="release/$(NAME)_{{.OS}}_{{.Arch}}_$(VERSION)" \
	  ./cmd/$(NAME)
	cd release/; for f in *; do mv -v $$f $(NAME); tar -zcf $$f.tar.gz $(NAME); rm $(NAME); done

deps:
	go get -t ./...
	go get github.com/mitchellh/gox

.PHONY: all build clean default deps release test
