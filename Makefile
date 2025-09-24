BATS_VERSION := v1.11.0
BATS_DIR := .bats
BATS := $(BATS_DIR)/bin/bats
BINARY := pomodoro

GO_SOURCES := $(shell find . -name '*.go' -not -path './vendor/*')

.PHONY: test
test: $(BINARY) $(BATS)
	$(BATS) test/

$(BINARY): $(GO_SOURCES) go.mod go.sum
	go build -o $(BINARY) .

$(BATS):
	@mkdir -p $(BATS_DIR)
	@echo "Downloading bats-core $(BATS_VERSION)..."
	@curl -sSL https://github.com/bats-core/bats-core/archive/$(BATS_VERSION).tar.gz | tar xz -C $(BATS_DIR) --strip-components=1
	@chmod +x $(BATS_DIR)/bin/bats

.PHONY: clean
clean:
	rm -rf $(BATS_DIR) $(BINARY)
