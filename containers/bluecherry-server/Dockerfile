# set a base image with environment to build from
FROM sicadaco/bluecherry-server:3.0.6

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /root

EXPOSE 7001/tcp 7002/tcp 554/tcp 554/udp

# This is the main script that runs as process ID 1 in the docker container
COPY entrypoint.sh /entrypoint.sh

CMD "/entrypoint.sh"
