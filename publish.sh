#!/bin/bash

echo "Regenerating static content"
hugo

echo "Adding content to ipfs"
hash=`ipfs add -r -q public | tail -1`
echo "Published to key $hash"

echo "Caching content in Infura"
curl "https://ipfs.infura.io:5001/api/v0/cat?arg=$hash/index.html&archive=false" -o /dev/null