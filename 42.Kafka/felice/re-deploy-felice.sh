#!/bin/bash

docker-compose pull felice-back felice-front
docker-compose up -d felice-back felice-front
docker image prune -fa
