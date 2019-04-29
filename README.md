# AWS Lambda function template in Go

## Overview

This AWS Lambda function template in Go implements HTTP routing.
It can also be run as a stand-alone web service.

## How to use locally

For developers, it is easiest to run the code locally as a web service:

### Build

```bash
make build
```

### Run

```bash
build/mylambda -webserver
```

- it will run the local webserver on port 3000 and accept connections.

```bash
curl localhost:3000
```

## How to use on AWS Lambda
The CircleCI configuration will deploy the code into AWS.
CircleCI has to have AWS access code ID and secret access key set up.