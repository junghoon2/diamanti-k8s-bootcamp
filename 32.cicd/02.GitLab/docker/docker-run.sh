docker run --detach \
    --hostname gitlab.dz-army.com \
    --publish 443:443 --publish 80:80 --publish 1022:22 --publish 5050:5050 \
    --name gitlab \
    --volume /srv/gitlab/config:/etc/gitlab \
    --volume /srv/gitlab/logs:/var/log/gitlab \
    --volume /srv/gitlab/data:/var/opt/gitlab \
    gitlab/gitlab-ee:latest
