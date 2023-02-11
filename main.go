package main

import (
	"context"
	"flag"
	"fmt"
	"log"
	"net"
	"net/http"

	"github.com/go-chi/chi"
	"github.com/go-chi/chi/middleware"
	"go.bug.st/serial"
	"google.golang.org/grpc"
	"roybunting.com/poc/golanggrpjfrog/protos"
)

var counter int

type grpcGreeterServer struct {
	protos.UnimplementedGreeterServer
}

func (s *grpcGreeterServer) SayHello(leCtx context.Context, leRequest *protos.HelloRequest) (*protos.HelloReply, error) {
	// No feature was found, return an unnamed feature
	counter++
	return &protos.HelloReply{Message: "HELLO " + leRequest.Name + "! ^.^" + fmt.Sprintf("%d", counter)}, nil
}

func main() {
	flag.Parse()
	lis, err := net.Listen("tcp", fmt.Sprintf("localhost:%d", 5555))
	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}
	var opts []grpc.ServerOption
	grpcServer := grpc.NewServer(opts...)
	protos.RegisterGreeterServer(grpcServer, &grpcGreeterServer{})
	grpcServer.Serve(lis)

	//Below code never executes, it's just here to allow this app to import the chi package
	r := chi.NewRouter()
	r.Use(middleware.Logger)
	r.Use(middleware.Recoverer)

	r.Get("/", func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte("root."))
	})

	http.ListenAndServe(":3333", r)
	ports, err := serial.GetPortsList()
	if err != nil {
		log.Fatal(err)
	}
	if len(ports) == 0 {
		log.Fatal("No serial ports found!")
	}
	for _, port := range ports {
		fmt.Printf("Found port: %v\n", port)
	}
}
