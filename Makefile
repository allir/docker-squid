DOCKER_REPO := allir/squid

SHORT_SHA := $(shell git rev-parse --short HEAD)
VERSION ?= $(shell (git describe --tags --dirty --match='v*' 2>/dev/null || echo v0.0.0) | cut -c2-)

.DEFAULT_GOAL := help
.PHONY: help
help: ## This help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST) | sort

.PHONY: print-version
print-version: ## Prints the checked out version or hash
	@echo $(DOCKER_REPO) version: $(VERSION)

.PHONY: clean
clean: ## Clean workspace
	@echo Workspace cleaned...
	@git clean -f

.PHONY: all
all: clean build release

.PHONY: build release
DOCKER_ARGS ?=
build: ## Build docker image
	@echo Building $(DOCKER_REPO)
	@docker build . -t $(DOCKER_REPO) $(DOCKER_ARGS)
	@echo Tagging $(DOCKER_REPO):$(VERSION)
	@docker tag $(DOCKER_REPO) $(DOCKER_REPO):$(VERSION)
	@echo Tagging $(DOCKER_REPO):$(SHORT_SHA)
	@docker tag $(DOCKER_REPO) $(DOCKER_REPO):$(SHORT_SHA)
	@echo 

release: build ## Push docker image to repository
	@echo Pushing $(DOCKER_REPO)
	@docker push $(DOCKER_REPO)
	@echo Pushing $(DOCKER_REPO):$(VERSION)
	@docker push $(DOCKER_REPO):$(VERSION)
	@echo Pushing $(DOCKER_REPO):$(SHORT_SHA)
	@docker push $(DOCKER_REPO):$(SHORT_SHA)
	@echo
