#!/usr/bin/bash
set -xe
install_path='/usr/share/nginx/html'

rm -rf public/

hugo

# Copy Pentacorn
cp pentacorn public/ -rfv

# Copy Bitcoin whitepaper
# Craig Wright sent a copyright infringement to some websites to remove the Bitcoin whitepaper and bitcoincore.org did it. Lol, lame.
cp bitcoin public/ -rfv

scp -r public/* daniel@papaya:$install_path/ 