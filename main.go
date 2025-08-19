package main

import (
	"flag"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
)

// defineFlags contains all the flag definitions, which are called before flag.Parse().
func parseFlags() {
	flag.Parse()
}

func main() {
	log.Printf("Server started.")
	parseFlags()

	router := http.NewServeMux()
	router.HandleFunc("/koala", HelloKoala)
	srv := &http.Server{
		Addr:    ":8080",
		Handler: router,
	}

	log.Fatal(srv.ListenAndServe())
}

func HelloKoala(w http.ResponseWriter, req *http.Request) {
	w.WriteHeader(http.StatusOK)
	VERSION, err := ioutil.ReadFile("VERSION")
	if err != nil {
		fmt.Fprintln(w, "Error reading VERSION file (existing-single-inrepo-port-ingress-autodeploy-20250819121010): "+err.Error())
		return
	}
	fmt.Fprintln(w, "Hello world! service:existing-single-inrepo-port-ingress-autodeploy-20250819121010 version: "+string(VERSION))
}
