SHELL := /bin/bash -euo pipefail

# Build info.
BUILDER := $(shell whoami)@$(shell hostname)
NOW := $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")

# Version Control.
VERSION := $(shell git describe --tags --dirty --always)
COMMIT := $(shell git rev-parse --short HEAD)
BRANCH := $(shell git rev-parse --abbrev-ref HEAD)

# Linker flags.
PKG := $(shell head -n 1 go.mod | cut -c 8-)
VER := $(PKG)/version
LDFLAGS := -s -w \
	-X $(VER).Version=$(or $(VERSION),unknown) \
	-X $(VER).Commit=$(or $(COMMIT),unknown) \
	-X $(VER).Branch=$(or $(BRANCH),unknown) \
	-X $(VER).BuiltAt=$(NOW) \
	-X $(VER).Builder=$(BUILDER)

TAG ?= $(PKG)
PWD := $(shell pwd)
GOLANG_CI_LINT_VERSION := v1.55.1
BINARY_NAME := app

.PHONY: lint test build build-local run run-local ci clean
lint:
	@go vet ./...
	@docker run -t --rm -v $(PWD):/app -w /app golangci/golangci-lint:$(GOLANG_CI_LINT_VERSION) golangci-lint run -v
test:
	@go test -v -race ./...
build:
	@docker build --build-arg LDFLAGS='$(LDFLAGS)' -t $(TAG) .
build-local:
	@CGO_ENABLED=0 go build -o $(BINARY_NAME) -ldflags '$(LDFLAGS)'
run:
	@docker run --rm $(TAG)
run-local:
	./$(BINARY_NAME)
ci: lint test build-local run-local
clean:
	@rm -f $(BINARY_NAME)
