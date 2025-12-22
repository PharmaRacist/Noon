#!/bin/bash

API_URL="https://zenquotes.io/api/random"
quote_line=$(curl -fs "$API_URL" | jq -r '.[0] | "\(.q)|\(.a)"')

# Validate output and print
if [ -n "$quote_line" ] && [[ "$quote_line" != "null|null" ]]; then
    echo "$quote_line"
else
    echo "Everything that irritates us about others can lead us to an understanding of ourselves.|Carl Jung"
fi
