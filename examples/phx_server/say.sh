#!/bin/bash
set -eu

json=$(
cat << EOS
  {
      "jsonrpc": "2.0",
      "method": "say",
      "params": [ "${1}" ]
  }
EOS
)

resp=$(
curl -D - -s --request POST 'http://localhost:4000/api/rpc' \
--header 'Content-Type: application/json' \
--data-raw "${json}"
)

echo "${resp}" | head -n 1
