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
RUN addgroup -g 1000 mcs
RUN adduser -u 1000 -G mcs -h /home/mcs -D mcs

# Copying patched papermc .jar from builder
COPY --from=builder /cache/patched_1.17.1.jar /home/mcs/server.jar

# Setting a volume for all external data (server configuration and world data)
VOLUME "/server"

# Setting working directory (we will run the server from here on container start)
WORKDIR /server

# Giving non-root user (mcs) access to write to /server directory
RUN chown -vR 1000:1000 /server

# Setting mcs as a default user when running this image
USER mcs

# Exposing minecraft ports
EXPOSE 25565/tcp
EXPOSE 25565/udp

# Setting default memory size (can be overridden by the build arg)
ARG ram=2G
ENV RAM=$ram

# Seting JAVA flags which will be used for server start procedure
ENV FLAGS="-XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1"

# Starting the server on container start
CMD echo "Starting PaperMC v1.17.1 Docker server:" && /opt/openjdk-16/bin/java -Xms${RAM} -Xmx${RAM} ${FLAGS} -jar /home/mcs/server.jar --nojline nogui