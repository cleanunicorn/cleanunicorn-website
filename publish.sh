#!/usr/bin/bash
set -xe
install_path='/usr/share/nginx/html'

rm -rf public/

hugo

# Copy Pentacorn
cp pentacorn public/ -rfv

# Build Santoku
cd projects/santoku
git pull
yarn
yarn build
cd ..
cp ./santoku/dist/* ../static/santoku/ -r
cd ..

scp -r public/* daniel@papaya:$install_path/ 