package main

import (
	"bytes"
	"fmt"
	"log"
	"net/http"
	"net"
	"encoding/json"
	"io"
)

func main() {
	fmt.Println("==> sending trace to Oju")
	send_trace_calculate_delta("calculating-delta")

	http.HandleFunc("/calculate-delta", func(writer http.ResponseWriter, request *http.Request) {
		fmt.Println("==> executing POST to delta")
		response, err := send_post_delta()
		if err != nil {
			fmt.Println("==> error on get request")
			fmt.Fprint(writer, "error on request to delta")
		} else {
			fmt.Println(response)
			fmt.Fprintf(writer, "The result of x^2 + 12x - 13 = 0 is: %s", response)
		}
	})
	log.Println("[BHASKARA] Listening on 8082")

	log.Fatal(http.ListenAndServe(":8082", nil))
}

func send_post_delta() (string, error) {
	json_body := []byte(`{"a": "1","b":"12","c":"-13"}`)

	request, err := http.NewRequest(http.MethodPost, "http://localhost:8081/check-delta", bytes.NewBuffer(json_body))
	if err != nil {
		return "", err
	}

	request.Header.Set("Content-Type", "application/json")
	client := &http.Client{}
	response, response_error := client.Do(request)
	if response_error != nil {
		fmt.Println("error on response: ", response_error.Error())
	}
	defer response.Body.Close()
	response_body, err := io.ReadAll(response.Body)
	if err != nil {
		fmt.Println("error on get request body: ", err.Error())
	}

	return string(response_body), nil
}

func send_trace_calculate_delta(span_name string) error {
	fields := map[string]interface{}{
		"name": span_name,
		"service": "delta",
		"attributes": map[string]string{
			"http.url": "http://delta.api.svc.cluster.local",
			"http.method": "POST",
			"http.body.a": "1",
			"http.body.b": "12",
			"http.body.c": "-13",
		},
	}

	json_string, err := json.Marshal(fields)

	if err != nil {
		return err 
	}

	trace_packet := "TRACE bhaskara AWO\n"+string(json_string)
	return send_tcp_packet(trace_packet)
}

func send_tcp_packet(packet string) error {
	conn, err := net.Dial("tcp", "localhost:9090")
	defer conn.Close()

	if err != nil {
		return err
	}

	_, write_error := conn.Write([]byte(packet))
	if write_error != nil {
		conn.Close()
		return write_error
	}
	return nil
}
