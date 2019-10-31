#!/usr/bin/bash
set -xe
install_path='/var/www/html'

rm -rf public/

hugo

# Copy Pentacorn
cp pentacorn public/ -rfv

scp -r public/* root@open.vpn:$install_path/ 