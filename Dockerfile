########################################## BUILDER ##########################################
FROM openjdk:16-alpine AS builder

MAINTAINER Volodymyr Sergeyev <volodymyr.sergeyev@gmail.com>

# Downloading latest papermc server .jar
ADD https://papermc.io/api/v1/paper/1.17.1/latest/download paper.jar

# Building patched papermc server .jar
RUN /opt/openjdk-16/bin/java -Dpaperclip.patchonly=true -jar /paper.jar; exit 0


########################################## SERVER ##########################################
FROM openjdk:16-alpine

MAINTAINER Volodymyr Sergeyev <volodymyr.sergeyev@gmail.com>

# Creating a non-root user (mcs)
RUN addgroup -g 1208 mcs
RUN adduser -u 1208 -G mcs -h /home/mcs -D mcs

# Copying patched papermc .jar from builder
COPY --from=builder /cache/patched_1.17.1.jar /server.jar

# Copying entrypoint script and making it executable
COPY ./entrypoint.sh /
RUN chmod +x /entrypoint.sh

# Setting a volume for all external data (server configuration and world data)
VOLUME "/server"

# Setting working directory (we will run the server from here on container start)
WORKDIR /server

# Giving non-root user (mcs) access to write to /server directory
RUN chown -vR 1208:1208 /server

# Setting mcs as a default user when running this image
USER mcs

# Exposing minecraft ports
EXPOSE 25565/tcp
EXPOSE 25565/udp

# Setting default memory size (can be overridden by the build arg)
ARG ram=2G
ENV RAM=$ram

# Running entrypoint script on container start
ENTRYPOINT ["/entrypoint.sh"]