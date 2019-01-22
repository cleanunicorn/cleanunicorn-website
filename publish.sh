#!/bin/bash

set -x

hugo

cp public/* /usr/share/nginx/html