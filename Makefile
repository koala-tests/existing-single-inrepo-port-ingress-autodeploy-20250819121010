SHELL := /bin/bash
.DEFAULT_GOAL := help

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: clean
clean: ## remove files created during build pipeline
	$(call print-target)
	rm -rf dist
	rm -f coverage.*
	rm -f '"$(shell go env GOCACHE)/../golangci-lint"'
	go clean -i -cache -testcache -modcache -fuzzcache -x

.PHONY: mod
mod: ## go mod tidy
	$(call print-target)
	go mod tidy
	cd tools && go mod tidy

.PHONY: inst
inst: ## go install tools
	$(call print-target)
	cd tools && go install $(shell cd tools && go list -f '{{ join .Imports " " }}' -tags=tools)

.PHONY: gen
gen: ## go generate
	$(call print-target)
	go generate ./...

LDFLAGS="-X main.version=$(shell git describe --tags --always --dirty)"

.PHONY: build
build: ## goreleaser build - no docker image, single target for local testing.
build:
	$(call print-target)
	goreleaser build --clean --single-target --snapshot

.PHONY: release
release: ## goreleaser release - build multi-arch, wrap in docker image.
release:
	$(call print-target)
	goreleaser release --clean --snapshot

.PHONY: lint
lint: ## golangci-lint
	$(call print-target)
	golangci-lint run

.PHONY: fix
fix: ## golangci-lint
	$(call print-target)
	golangci-lint run --fix

.PHONY: test
test: ## go test
	$(call print-target)
	go test -race -covermode=atomic -coverprofile=coverage.out -coverpkg=./... ./...
	go tool cover -html=coverage.out -o coverage.html


define print-target
    @printf "Executing target: \033[36m$@\033[0m\n"
endef