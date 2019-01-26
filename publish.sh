#!/usr/bin/bash
set -xe
install_path='/var/www/html'

rm -rf public/

/usr/bin/hugo
scp -r public/* root@open.vpn:$install_path/ 