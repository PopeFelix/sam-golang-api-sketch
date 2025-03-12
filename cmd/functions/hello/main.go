package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
)

type response struct {
	Message string `json:"greeting"`
}

func init() {
}

func handleRequest(ctx context.Context, request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	name := request.PathParameters["name"]
	eventJson, _ := json.MarshalIndent(request, "", "  ")
	log.Printf("EVENT: %s", eventJson)
	resp := &response{
		Message: fmt.Sprintf("hello %s!", name),
	}
	body, err := json.Marshal(resp)
	if err != nil {
		return events.APIGatewayProxyResponse{Body: string("Error parsing payload"), StatusCode: 400}, err
	}
	return events.APIGatewayProxyResponse{Body: string(body), StatusCode: 200}, nil
}

func main() {
	lambda.Start(handleRequest)
}
