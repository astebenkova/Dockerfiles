#!/bin/bash

PUSHGATEWAY_SERVER=http://ip_addr:9091
NODE_NAME=`hostname`
NODE_EXPORTER_PORT=9100

curl -s http://localhost:${NODE_EXPORTER_PORT}/metrics | grep -Ev 'go_|http_request|http_requests|http_response|process_' | curl --data-binary @- ${PUSHGATEWAY_SERVER}/metrics/job/node-exporter/instance/${NODE_NAME}
