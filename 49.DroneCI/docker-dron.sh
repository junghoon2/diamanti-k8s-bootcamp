docker run \
  --volume=/var/lib/drone:/data \
  --env=DRONE_GITLAB_SERVER=https://gitlab.spkr.io \
  --env=DRONE_GITLAB_CLIENT_ID=5b94d9903b24b96500a2426ca04a388cb264c98306bb0faac0afffca579b2623 \
  --env=DRONE_GITLAB_CLIENT_SECRET=c507a5b6a579f16a2854b11c4bce7fc626d27c6287cff5244879874b42854bc0 \
  --env=DRONE_RPC_SECRET=9b61384b60d26c015350ba3b2068b9c7 \
  --env=DRONE_SERVER_HOST=172.17.16.181 \
  --env=DRONE_SERVER_PROTO=http \
  --add-host="gitlab.spkr.io:172.17.16.182" \
  --publish=80:80 \
  --publish=443:443 \
  --restart=always \
  --detach=true \
  --name=drone \
  drone/drone:1


 docker run -d \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -e DRONE_RPC_PROTO=http \
  -e DRONE_RPC_HOST=172.17.16.181 \
  -e DRONE_RPC_SECRET=9b61384b60d26c015350ba3b2068b9c7 \
  -e DRONE_RUNNER_CAPACITY=2 \
  -e DRONE_RUNNER_NAME=${HOSTNAME} \
  -p 3000:3000 \
  --restart always \
  --name runner \
  drone/drone-runner-docker:1
