BINARY_NAME=spotify-sleeptimer
BINARY_FILE_PATH=".build-artifacts/$(BINARY_NAME)"
MAIN_FILE="cmd/main.go"

setup: install-statics ## Install tools
	curl -sfL https://install.goreleaser.com/github.com/golangci/golangci-lint.sh | bash -s v1.33.0
	mv bin/golangci-lint $(GOPATH)/bin/golangci-lint && rm -rf bin

install-statics:
	go get -u github.com/go-playground/statics

lint: ## Run the linters
	golangci-lint run

test: ## Run all the tests
	go version
	go env
	go list ./... | xargs -n1 -I{} sh -c 'go test -race {}'

fmt: ## gofmt and goimports all go files
	find . -name '*.go' -not -wholename './vendor/*' | while read -r file; do gofmt -w -s "$$file"; goimports -w "$$file"; done

generate-assets: ## generates static assets
	statics -i=assets/files -o=assets/files.go  -pkg=assets -group=Assets .env-ignore=\.gitignore -prefix=assets
	statics -i=assets/css   -o=assets/css.go    -pkg=assets -group=Css    .env-ignore=\.gitignore -prefix=assets
	statics -i=assets/img   -o=assets/img.go    -pkg=assets -group=Iages  .env-ignore=\.gitignore -prefix=assets
	statics -i=assets/fonts -o=assets/fonts.go  -pkg=assets -group=Fonts  .env-ignore=\.gitignore -prefix=assets

build: ## build binary to .build folder
	rm -f $(BINARY_FILE_PATH) 
	go build -o $(BINARY_FILE_PATH) $(MAIN_FILE)

build-full: install-statics generate-assets build

deploy:
	build-spotify-sleeptimer
	deploy-spotify-sleeptimer

# Self-Documented Makefile see https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
help:
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help