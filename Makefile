GOPATH ?= $(shell go env GOPATH)
export GO111MODULE=on

########################################
### Build

build:
	go build -ldflags "-extldflags \"-static\"" -o build/aws-lambda-go-template .

build-linux:
	GOOS=linux GOARCH=amd64 $(MAKE) build


########################################
### Testing

test:
	go test -cover -race ./...

########################################
### Linting

$(GOPATH)/bin/golangci-lint:
	GO111MODULE=off go get -u github.com/golangci/golangci-lint/cmd/golangci-lint

lint: $(GOPATH)/bin/golangci-lint
	$(GOPATH)/bin/golangci-lint run ./...

########################################
### Localnet

localnet-start:
	build/aws-lambda-go-template -webserver

localnet-lambda:
	# (Requirements: pip3 install aws-sam-cli)
	sam local start-api

.PHONY: build build-linux test localnet-start localnet-lambda
