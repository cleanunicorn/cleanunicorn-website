#!/usr/bin/bash
set -xe
install_path='/var/www/html'

rm -rf public/

~/go/bin/hugo
scp -rv public/* root@open.vpn:$install_path/ 