#!/bin/bash

install_path='/var/www/html'

hugo
scp -rv public/* root@open.vpn:$install_path/ 