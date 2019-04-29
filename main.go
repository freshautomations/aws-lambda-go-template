// main package that executes the code
package main

import (
	"encoding/json"
	"fmt"
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/awslabs/aws-lambda-go-api-proxy/gorillamux"
	"github.com/gorilla/mux"
	"github.com/spf13/pflag"
	"github.com/spf13/viper"
	"github.com/tomasen/realip"
	"log"
	"os/signal"
	"syscall"

	"net/http"
	"os"
	"time"
)

// Handler is an abstraction layer for implementing ServeHTTP.
type Handler struct {
	HandlerFunc func(http.ResponseWriter, *http.Request) (int, error)
}

// ServeHTTP implementation with default error response. https://golang.org/src/net/http/server.go?s=2736:2799#L75
func (fn Handler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	if status, err := fn.HandlerFunc(w, r); err != nil {
		w.WriteHeader(status)
		_ = json.NewEncoder(w).Encode(struct {
			Message string `json:"message"`
		}{Message: err.Error()})
		log.Printf("%d %s", status, err.Error())
	}
}

// lambdaInitialized is an indicator that tells if the AWS Lambda function is in the startup phase.
var lambdaInitialized = false

// Translates Gorilla Mux calls to AWS API Gateway calls
var lambdaProxy func(request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error)

// LambdaHandler is the callback function for the AWS Lambda function.
func LambdaHandler(req events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	if !lambdaInitialized {
		// stdout and stderr are sent to AWS CloudWatch Logs
		log.Print("cold start")

		r := AddRoutes()
		muxLambda := gorillamux.New(r)
		lambdaProxy = muxLambda.Proxy

		lambdaInitialized = true
	}

	return lambdaProxy(req)
}

// WebServerHandler sets up a local web server for handling incoming requests.
func WebServerHandler(ip string, port int) {
	log.Print("web server execution start")

	r := AddRoutes()

	srv := &http.Server{
		Addr: fmt.Sprintf("%s:%d", ip, port),
		// Good practice to set timeouts to avoid Slowloris attacks.
		WriteTimeout: time.Second * 30,
		ReadTimeout:  time.Second * 30,
		IdleTimeout:  time.Second * 60,
		Handler:      r,
	}

	// Manage signals for graceful exit
	var gracefulStop = make(chan os.Signal)
	signal.Notify(gracefulStop, syscall.SIGTERM)
	signal.Notify(gracefulStop, syscall.SIGINT)
	go func() {
		sig := <-gracefulStop
		log.Printf("caught signal: %+v", sig)
		log.Print("waiting 2 seconds to finish processing")
		time.Sleep(2 * time.Second)
		os.Exit(0)
	}()

	if err := srv.ListenAndServe(); err != nil {
		log.Fatal(err)
	}
}

// MainHandler handles the requests coming to `/`.
func MainHandler(w http.ResponseWriter, _ *http.Request) (status int, err error) {

	// Todo: Build your function

	w.Header().Set("Content-Type", "application/json; charset=utf8")
	_ = json.NewEncoder(w).Encode(struct {
		Message string `json:"message"`
	}{
		Message: fmt.Sprintf("Hello %s", viper.GetString("mysetting1")),
	})

	return
}

// Create logs for each request
func loggingMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		log.Printf("[%s] %s", realip.FromRequest(r), r.RequestURI)
		next.ServeHTTP(w, r)
	})
}

// AddRoutes adds the routes of the different calls to GorillaMux.
func AddRoutes() (r *mux.Router) {

	// Gorilla/Mux
	r = mux.NewRouter()

	// Todo: Add your routes

	_ = r.Handle("/", Handler{HandlerFunc: MainHandler})

	// Finally
	r.Use(loggingMiddleware)

	return
}

func main() {

	// Parse command-line parameters
	pflag.Bool("version", false, "Return version number and exit.")
	pflag.Bool("webserver", false, "run a local web-server instead of as an AWS Lambda function")
	pflag.String("config", "", "read config from this local file")
	pflag.String("ip", "127.0.0.1", "IP to listen on")
	pflag.Uint("port", 3000, "Port to listen on")
	pflag.Parse()
	_ = viper.BindPFlags(pflag.CommandLine)

	// Todo: Set defaults for configuration variables
	viper.SetDefault("mysetting1", "world")

	// Parse configuration from optional config file
	if viper.GetString("config") != "" {
		viper.SetConfigFile(viper.GetString("config"))
		err := viper.ReadInConfig() // Find and read the config file
		if err != nil {             // Handle errors reading the config file
			panic(fmt.Errorf("Fatal error config file: %s \n", err))
		}
	}
	// Enable peek at environment variables for configuration settings.
	viper.AutomaticEnv()

	if viper.GetBool("version") {
		// Todo: Set version number
		fmt.Println("v0.0.0")
		return
	}

	if viper.GetBool("webserver") {
		WebServerHandler(viper.GetString("ip"), viper.GetInt("port"))
		return
	}

	//Lambda function on AWS
	lambda.Start(LambdaHandler)
}
