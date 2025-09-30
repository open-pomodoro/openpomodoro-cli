BINARY := pomodoro

GO_SOURCES := $(shell find . -name '*.go' -not -path './vendor/*')
VERSION := $(shell git describe --tags --exact-match 2>/dev/null || git rev-parse --short HEAD 2>/dev/null || echo "dev")
LDFLAGS := -X main.Version=$(VERSION)

BATS_VERSION := v1.12.0
BATS_SUPPORT_VERSION := v0.3.0
BATS_ASSERT_VERSION := v2.1.0
BATS_DIR := test/.bats

BATS_CORE := $(BATS_DIR)/bats-core
BATS_SUPPORT := $(BATS_DIR)/bats-support
BATS_ASSERT := $(BATS_DIR)/bats-assert

.PHONY: test
test: test-unit test-acceptance

.PHONY: test-unit
test-unit:
	go test ./...

.PHONY: test-acceptance
test-acceptance: $(BINARY) $(BATS_CORE) $(BATS_SUPPORT) $(BATS_ASSERT)
	$(BATS_CORE)/bin/bats test/

$(BINARY): $(GO_SOURCES) go.mod go.sum
	go build -ldflags "$(LDFLAGS)" -o $(BINARY) .

.PHONY: install
install:
	go install ./cmd/pomodoro

.PHONY: clean
clean:
	rm -rf $(BINARY) $(BATS_DIR)

$(BATS_CORE):
	@echo "Downloading bats-core $(BATS_VERSION)..."
	@mkdir -p $(BATS_DIR)/tmp
	@curl -sSL https://github.com/bats-core/bats-core/archive/$(BATS_VERSION).tar.gz | tar xz -C $(BATS_DIR)/tmp
	@mkdir -p $(BATS_CORE)/bin $(BATS_CORE)/lib/bats-core $(BATS_CORE)/libexec/bats-core
	@cp $(BATS_DIR)/tmp/bats-core-*/bin/bats $(BATS_CORE)/bin/
	@cp $(BATS_DIR)/tmp/bats-core-*/lib/bats-core/*.bash $(BATS_CORE)/lib/bats-core/
	@cp $(BATS_DIR)/tmp/bats-core-*/libexec/bats-core/* $(BATS_CORE)/libexec/bats-core/
	@chmod +x $(BATS_CORE)/bin/bats $(BATS_CORE)/libexec/bats-core/*
	@rm -rf $(BATS_DIR)/tmp

$(BATS_SUPPORT):
	@echo "Downloading bats-support $(BATS_SUPPORT_VERSION)..."
	@mkdir -p $(BATS_DIR)/tmp
	@curl -sSL https://github.com/bats-core/bats-support/archive/$(BATS_SUPPORT_VERSION).tar.gz | tar xz -C $(BATS_DIR)/tmp
	@mkdir -p $(BATS_SUPPORT)/src
	@cp $(BATS_DIR)/tmp/bats-support-*/load.bash $(BATS_SUPPORT)/
	@cp $(BATS_DIR)/tmp/bats-support-*/src/*.bash $(BATS_SUPPORT)/src/
	@rm -rf $(BATS_DIR)/tmp

$(BATS_ASSERT):
	@echo "Downloading bats-assert $(BATS_ASSERT_VERSION)..."
	@mkdir -p $(BATS_DIR)/tmp
	@curl -sSL https://github.com/bats-core/bats-assert/archive/$(BATS_ASSERT_VERSION).tar.gz | tar xz -C $(BATS_DIR)/tmp
	@mkdir -p $(BATS_ASSERT)/src
	@cp $(BATS_DIR)/tmp/bats-assert-*/load.bash $(BATS_ASSERT)/
	@cp $(BATS_DIR)/tmp/bats-assert-*/src/*.bash $(BATS_ASSERT)/src/
	@rm -rf $(BATS_DIR)/tmp
