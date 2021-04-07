NAME=local-demo
VERSION=0.0.15
VERBOSE=1
DOCKER_HUB=bics101
DOCKERFILE="app/Dockerfile"
CLUSTER="arn:aws:eks:eu-west-2:778136737248:cluster/test"
export TERM=xterm

SET_ENVIRONMENT ?= $(strip $(if $(ENVIRONMENT),$(ENVIRONMENT),nodummy))
.PHONY: all

.DEFAULT: help

help: ## Show help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

build: ## Build docker image
	docker build -t $(DOCKER_HUB)/$(NAME):$(VERSION) --rm app
	docker push $(DOCKER_HUB)/$(NAME):$(VERSION)

deploy: ## Deploy container
	 env VERSION=$(VERSION) aws-vault exec megaloop -- kd --context=$(CLUSTER) \
		--file k8s/ --namespace default
release: build deploy

git-tag: ## Create release and tag
	git tag -s -a v$(VERSION) -m "v$(VERSION)"
	git push origin v$(VERSION)
git-tag-version: release ## Create release and tag
	git tag -s -a v$(VERSION) -m "v$(VERSION)"
	git push origin v$(VERSION)

