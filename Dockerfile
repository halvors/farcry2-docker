FROM ubuntu:18.04

LABEL maintainer="https://github.com/halvors/farcry2-docker"

ARG USER=farcry2
ARG GROUP=farcry2
ARG PUID=845
ARG PGID=845

ENV SHA256=281e69fc0cccfa4760ba8db3b82315f52d2f090d9d921dc3adc89afbf046898a \
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
    apt-get install -y curl gcc libc6-dev-i386 sudo lib32stdc++6 lib32ncurses5 lib32z1 && \
    curl -sSL "$url" -o "$archive" && \
    echo "$SHA256  $archive" | sha256sum -c || \
    (sha256sum "$ARCHIVE_FILE" && file "$ARCHIVE_FILE" && exit 1) && \
    tar xzf "$archive" --directory /opt && \
    mv $directory /opt/farcry2 && \
    rm "$archive" && \
    gcc /patch.c -shared -fPIC -ldl -o /opt/farcry2/bin/patch.so -m32 && \
    rm /patch.c && \
    chmod ugo=rwx /opt/farcry2 && \
    groupadd -g "$PGID" "$GROUP" && \
    useradd -u "$PUID" -g "$GROUP" -s /bin/sh "$USER" && \
    chown -R "$USER":"$GROUP" /opt/farcry2 /farcry2 && \
    apt-get purge -y curl gcc libc6-dev-i386 && \
    apt-get autoremove -y --purge

VOLUME /farcry2

EXPOSE 9000-9003/udp 9000-9003/tcp

ENTRYPOINT ["/docker-entrypoint.sh"]
