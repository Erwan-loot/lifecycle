FROM alpine:latest

RUN apk add --no-cache docker-cli curl

COPY watch_docker_events.sh /watch_docker_events.sh

RUN chmod +x /watch_docker_events.sh

CMD ["/watch_docker_events.sh"]
