#!/bin/bash

PUSHGATEWAY_SERVER=http://ip-address:9091
NODE_NAME=`hostname`

curl -s http://localhost:9100/metrics | grep -Ev 'go_|http_request|http_requests|http_response|process_' | curl --data-binary @- ${PUSHGATEWAY_SERVER}/metrics/job/node-exporter/instance/${NODE_NAME}
