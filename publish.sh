#!/usr/bin/bash
set -xe
install_path='/usr/share/nginx/html'

rm -rf public/

hugo

# Copy Pentacorn
cp pentacorn public/ -rfv

# Copy ABI Decoder
cp abi-decoder public/ -rfv

scp -r public/* daniel@papaya:$install_path/ 