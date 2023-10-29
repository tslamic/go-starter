# Defaults.
SHELL := /bin/bash -euo pipefail
GOLANG_CI_LINT_VERSION := v1.55.1
PACKAGE_NAME := $(shell head -n 1 go.mod | cut -c 8-)
DOCKER_TAG ?= $(PACKAGE_NAME)
PWD := $(shell pwd)
CGO := 0

# Build info.
BUILDER := $(shell whoami)@$(shell hostname)
NOW := $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")

# Version Control.
VERSION := $(shell git describe --tags --dirty --always)
COMMIT := $(shell git rev-parse --short HEAD)
BRANCH := $(shell git rev-parse --abbrev-ref HEAD)

# Linker flags.
SRC := $(PACKAGE_NAME)/version
LDFLAGS := "-s -w \
	-X $(SRC).Version=$(or $(VERSION),unknown) \
	-X $(SRC).Commit=$(or $(COMMIT),unknown) \
	-X $(SRC).Branch=$(or $(BRANCH),unknown) \
	-X $(SRC).BuiltAt=$(NOW) \
	-X $(SRC).Builder=$(BUILDER)"

.PHONY: default lint test build build-local run run-local clean

default: lint test build-local run-local

lint:
	@docker run -t --rm -v $(PWD):/app -w /app golangci/golangci-lint:$(GOLANG_CI_LINT_VERSION) golangci-lint run -v
test:
	@go test -v -race ./...
build:
	@docker build --build-arg LDFLAGS=$(LDFLAGS) CGO_ENABLED=$(CGO) -t $(DOCKER_TAG) .
build-local:
	@LDFLAGS=$(LDFLAGS) CGO_ENABLED=$(CGO) ./bin/build.sh
run:
	@docker run --rm $(DOCKER_TAG)
run-local:
	./app
clean:
	@rm -f ./app
