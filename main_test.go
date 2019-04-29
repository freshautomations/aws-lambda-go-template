package main

import (
	"github.com/spf13/viper"
	"net/http"
	"net/http/httptest"
	"testing"
)

func Test_MainHandler(t *testing.T) {
	viper.Set("mysetting1", "world")
	rr := httptest.NewRecorder()
	req, err := http.NewRequest("GET", "/", nil)
	if err != nil {
		t.Fatal(err)
	}
	handler := Handler{HandlerFunc: MainHandler}
	handler.ServeHTTP(rr, req)

	if status := rr.Code; status != http.StatusOK {
		t.Errorf("handler returned wrong status code: got %v want %v", status, http.StatusOK)
	}

	expected := "{\"message\":\"Hello world\"}\n"

	if rr.Body.String() != expected {
		t.Errorf("handler returned unexpected body: got %v want %v", rr.Body.String(), expected)
	}
}
