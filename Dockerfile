FROM ubuntu:18.04

LABEL maintainer="https://github.com/halvors/farcry2-docker"

ARG USER=farcry2
ARG GROUP=farcry2
ARG PUID=845
ARG PGID=845

ENV SHA256=281e69fc0cccfa4760ba8db3b82315f52d2f090d9d921dc3adc89afbf046898a \
    CONFIG=/farcry2/config \
    MAPS=/farcry2/user\ maps \
    USER="$USER" \
    GROUP="$GROUP" \
    PUID="$PUID" \
    PGID="$PGID"

COPY files/ /

RUN set -x && \
    url="https://static3.cdn.ubi.com/far_cry_2/FarCry2_Dedicated_Server_Linux.tar.gz" && \
    archive="/tmp/FarCry2_Dedicated_Server_Linux.tar.gz" && \
    directory="/opt/FarCry2_Dedicated_Server_Linux" && \
    mkdir -p /opt /farcry2 && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y curl lib32stdc++6 lib32ncurses5 lib32z1 && \
    curl -sSL "$url" -o "$archive" && \
    echo "$SHA256  $archive" | sha256sum -c || \
    (sha256sum  "$ARCHIVE_FILE" && file "$ARCHIVE_FILE" && exit 1) && \
    tar xzf "$archive" --directory /opt && \
    mv $directory /opt/farcry2 && \
    chmod ugo=rwx /opt/farcry2 && \
    rm "$archive" && \

#    rm /opt/farcry2/bin/pb/htm/* && \
#    rm /opt/farcry2/bin/pb/*.db && \
#    rm /opt/farcry2/bin/pb/*.dat && \

#    mkdir /opt/farcry2/bin/pb/dll && \
#    mv /pb/dll/*.* /opt/farcry2/bin/pb/dll && \
#    rmdir /pb/dll && \
#    mv /pb/htm/*.* /opt/farcry2/bin/pb/htm && \
#    rmdir /pb/htm && \
#    mv /pb/*.* /opt/farcry2/bin/pb && \
#    rmdir /pb && \
#    ln -s "$MAPS" /opt/farcry2/user\ maps && \
    groupadd -g "$PGID" "$GROUP" && \
    useradd -u "$PUID" -g "$GROUP" -s /bin/sh "$USER" && \
    chown -R "$USER":"$GROUP" /opt/farcry2 /farcry2

#    echo "sv_punkbuster 1" > /opt/farcry2/bin/pb/pbsvgame.cfg

VOLUME /farcry2

EXPOSE 9000-9003/udp 9000-9003/tcp

ENTRYPOINT ["/docker-entrypoint.sh"]
