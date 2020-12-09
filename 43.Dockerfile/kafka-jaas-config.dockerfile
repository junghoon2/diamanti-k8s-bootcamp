FROM docker.io/bitnami/kafka:2.6.0-debian-10-r78

COPY kafka_jaas.conf /opt/bitnami/kafka/config/kafka_jaas.conf