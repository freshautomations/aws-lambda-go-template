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

########################################
### Deploy

# Make sure your AWS credentials are in place.
deploy:
	file build/aws-lambda-go-template | grep ELF || (echo "Please build a linux binary." && false)
	zip build/mylambda.zip build/aws-lambda-go-template
	cd terraform && terraform init && terraform apply --auto-approve

destroy:
	cd terraform && terraform destroy

.PHONY: build build-linux test localnet-start localnet-lambda deploy destroy

