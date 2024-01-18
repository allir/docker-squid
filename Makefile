#https://clarkgrubb.com/makefile-style-guide
MAKEFLAGS += --warn-undefined-variables
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:

# Common variables
empty :=
space := $(empty) $(empty)
comma := ,

# Git SHA and tag Information
git_branch	     = $(shell git rev-parse --abbrev-ref HEAD)
git_sha          = $(shell git describe --match=NeVeRmAtCh --always --abbrev=40 --dirty)
git_short_sha    = $(shell git describe --match=NeVeRmAtCh --always --dirty)
git_tag          = $(shell git describe --tags --always --dirty)
git_version_tag  = $(shell git tag --points-at HEAD | grep -P '^v\d+\.\d+(-.+)?$$' || echo $(git_branch)-$(git_short_sha))

.DEFAULT_GOAL := help
.PHONY: help
help: ## This help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST) | sort

.PHONY: print-version
print-version: ## Prints the checked out version or hash
	@echo $(DOCKER_REPO) version: $(git_version_tag)

.PHONY: clean
clean: ## Clean workspace
	@echo Workspace cleaned...
	@git clean -f

.PHONY: all
all: clean docker-build docker-release

docker := $(shell command -v docker 2> /dev/null)
DOCKER_REPO ?= allir/squid
DOCKER_ARGS ?=
DOCKER_PLATFORMS ?= linux/amd64,linux/arm64
DOCKER_TAG  ?= latest
docker_tags := --tag $(DOCKER_REPO):$(DOCKER_TAG)
release_tags := $(docker_tags) --tag $(DOCKER_REPO):$(git_version_tag)

.PHONY: docker-build
docker-build: ## Build docker image
ifeq (, $(docker))
	$(error "docker is not available please install docker")
endif
	@echo Building $(DOCKER_REPO)
	@docker buildx build . $(DOCKER_ARGS) $(docker_tags) --load
	@echo 

.PHONY: docker-release
docker-release: docker-build ## Push docker image to repository
ifeq (, $(docker))
	$(error "docker is not available please install docker")
endif
	@echo Release $(DOCKER_REPO)
	@docker buildx build . $(release_tags) $(docker_tags) --platform $(DOCKER_PLATFORMS) --push
	@echo
