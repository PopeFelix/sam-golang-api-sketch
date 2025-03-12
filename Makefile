# the name of the AWS Profile you want to use
OUTPUT = cmd/functions/hello/bootstrap # Referenced as Handler in template.yaml
PACKAGED_TEMPLATE = package.yaml
STACK_NAME := $(STACK_NAME)
AWS_REGION := $(AWS_REGION)
AWS_PROFILE := $(AWS_PROFILE)
TEMPLATE = template.yaml
LDFLAGS = -ldflags="-s -w"
GOOS=linux
GOARCH=arm64
CGO_ENABLED=0

.PHONY: test
test:
	go test ./...

.PHONY: clean
clean:
	rm -f $(OUTPUT) $(PACKAGED_TEMPLATE)

.PHONY: install
install:
	go get ./...

main: ./cmd/functions/hello/main.go
	go build $(LDFLAGS) -o $(OUTPUT) ./cmd/functions/hello/main.go

# compile the code to run in Lambda (local or real)
.PHONY: lambda
lambda:
	GOOS=linux GOARCH=$(GOARCH) $(MAKE) main

.PHONY: build
build: clean lambda

.PHONY: api
api: build
	sam local start-api

.PHONY: package
package: build
	sam package --template-file $(TEMPLATE) --output-template-file $(PACKAGED_TEMPLATE) --region $(AWS_REGION)

.PHONY: deploy
deploy: package
	sam deploy --stack-name $(STACK_NAME) --template-file $(PACKAGED_TEMPLATE) --capabilities CAPABILITY_IAM

.PHONY: publish 
publish: package
	sam publish  --template $(PACKAGED_TEMPLATE) --profile $(AWS_PROFILE)