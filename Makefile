SHELL = bash

# Build info.
BUILDER = $(shell whoami)@$(shell hostname)
NOW = $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")

# Version Control.
VERSION = $(shell git describe --tags --dirty --always)
COMMIT = $(shell git rev-parse --short HEAD)
BRANCH = $(shell git rev-parse --abbrev-ref HEAD)

# Linker flags.
PKG = $(shell head -n 1 go.mod | cut -c 8-)
VER = $(PKG)/version
LDFLAGS = -s -w \
	-X $(VER).Version=$(or $(VERSION),unknown) \
	-X $(VER).Commit=$(or $(COMMIT),unknown) \
	-X $(VER).Branch=$(or $(BRANCH),unknown) \
	-X $(VER).BuiltAt=$(NOW) \
	-X $(VER).Builder=$(BUILDER)

.PHONY: lint
lint:
	go vet && golangci-lint run ./...

.PHONY: test
test:
	go test -v -race ./...

.PHONY: build
build:
	@docker build --build-arg LDFLAGS='$(LDFLAGS)' -t $(or $(TAG),$(PKG)) .

.PHONY: build-local
build-local:
	CGO_ENABLED=0 sh -c "go build -o app -ldflags '${LDFLAGS}'"
