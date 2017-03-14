#!/bin/bash

rm -rf tmp/pids/server.pid
rackup private_pub.ru -s thin -o 0.0.0.0 -D -E production
bundle exec rails s -p 80 -b '0.0.0.0'
