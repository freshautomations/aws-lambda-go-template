[![CircleCI](https://circleci.com/gh/freshautomations/aws-lambda-go-template/tree/master.svg?style=svg)](https://circleci.com/gh/freshautomations/aws-lambda-go-template/tree/master)

# AWS Lambda function template in Go

## Overview

This AWS Lambda function template in Go
* implements HTTP routing using Gorilla/Mux
* reads configuration from environment variables
* it can also be run as a stand-alone web server
* the standalone web server can also read configuration from a file
* uses viper to allow YAML, JSON and other configuration file types.

## How to start developing with the template

The template runs as-is as a "Hello world" application.
Add your custom code at the "// Todo:" comments to make it useful.

* Build your functionality for the `/` page in the `MainHandler` function.
* Create additional web Handler functions and register them as a Gorilla/Mux route
in the `AddRoutes` function.
* Set configuration defaults for unset variables in the `main` function.
* Set a version number in the `main` function.

### Build

```bash
make build
```

### Run

```bash
build/mylambda -webserver
```

* it will run the local webserver on port 3000 by default.

```bash
curl localhost:3000
```

## How to use on AWS Lambda
The CircleCI configuration will deploy the code into AWS.
CircleCI has to have AWS access code ID and secret access key set up.
