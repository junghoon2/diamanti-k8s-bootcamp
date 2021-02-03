docker run -d \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -e DRONE_RPC_PROTO=http \
  -e DRONE_RPC_HOST='172.17.28.101' \
  -e DRONE_RPC_SECRET=39cc97c4cff72612218df3269b149ae5 \
  -e DRONE_RUNNER_CAPACITY=2 \
  -e DRONE_RUNNER_NAME=drone-spkr \
  -e DRONE_UI_USERNAME=root \
  -e DRONE_UI_PASSWORD=root \
  -p 3000:3000 \
  --restart always \
  --name runner \
  drone/drone-runner-docker:1

  # --add-host='drone.spkr.io:127.0.0.1' \

docker run \
  --volume=/var/lib/drone:/data \
  -e DRONE_GITLAB_SERVER=https://gitlab.spkr.io \
  -e DRONE_GITLAB_CLIENT_ID=5b94d9903b24b96500a2426ca04a388cb264c98306bb0faac0afffca579b2623 \
  -e DRONE_GITLAB_CLIENT_SECRET=c507a5b6a579f16a2854b11c4bce7fc626d27c6287cff5244879874b42854bc0 \
  -e DRONE_RPC_SECRET=39cc97c4cff72612218df3269b149ae5 \
  -e DRONE_SERVER_HOST='172.17.28.101' \
  -e DRONE_SERVER_PROTO=http \
  --publish=80:80 \
  --publish=443:443 \
  --restart=always \
  --detach=true \
  --name=drone \
  --add-host='gitlab.spkr.io:172.17.16.182' \
  drone/drone:1

  # --add-host='gitlab.spkr.io:172.17.16.182' \
