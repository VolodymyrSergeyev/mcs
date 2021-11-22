#!/bin/sh

# Seting JAVA flags which will be used for server start procedure
FLAGS="-XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1"

if ! test -f "/server/eula.txt"; then
    echo "Initialising the server:"

    # On the first run starting the server waiting for it to fail due to eula=false then editing eula file
    echo "---> Running the server for the first time"
    /opt/openjdk-16/bin/java -Xms$RAM -Xmx$RAM $FLAGS -jar /server.jar nogui

    echo "---> Aggreeing to EULA"
    sed -i 's/eula=false/eula=true/g' /server/eula.txt
    echo "---> Initialisation completed"
fi

echo "Starting PaperMC v1.17.1 Docker server:"
/opt/openjdk-16/bin/java -Xms$RAM -Xmx$RAM $FLAGS -jar /server.jar nogui