#!/bin/bash
dokcer stop atasdev
docker rm atasdev
docker run --name atasdev --net if01 -e VIRTUAL_HOST=atas.agenciahacker.com.br -e SECRET_KEY_BASE=c1ae3b48c17d5373cd4292bb25fd685d078215be76e8a2ea65e28da1bbbeede9d8c9699841e3c729f8f2ea99423dee04df3d4fe179cba648671d439bda54a2ae  --link postgres:db --expose 80 -p 9292:9292 -v /home/docker-workspace/atas/:/myapp -it atas_web bash
