#!/bin/bash
set -eu

id=$(date +%s)

json=$(
cat << EOS
  {
      "jsonrpc": "2.0",
      "id": ${id},
      "method": "add",
      "params": [
          ${1},
          ${2}
      ]
  }
EOS
)

resp=$(
curl -D - -s --request POST 'http://localhost:4000/api/rpc' \
--header 'Content-Type: application/json' \
--data-raw "${json}"
)

echo "${resp}" | head -n 1
echo "${resp}" | tail -n 1
