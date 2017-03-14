#!/bin/bash

docker-compose stop
docker rm atas
git pull origin master
docker-compose up -d
docker exec atas rake db:migrate RAILS_ENV=development
