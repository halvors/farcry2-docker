FROM ubuntu:20.04

LABEL maintainer="https://github.com/halvors/farcry2-docker"

ARG DEBIAN_FRONTEND=noninteractive

ARG USER=farcry2
ARG GROUP=farcry2
ARG PUID=845
ARG PGID=845

ENV CHECKSUM_LINUX="281e69fc0cccfa4760ba8db3b82315f52d2f090d9d921dc3adc89afbf046898a" \
    CHECKSUM_WIN32="714b855adadfaf4773affd74be3e70f9df679293504ca06e6e0b54d2205eb6c0" \
    ARCHIVE_LINUX="/tmp/FarCry2_Dedicated_Server_Linux.tar.gz" \
    ARCHIVE_WIN32="/tmp/FC2ServerLauncher_103_R2.rar" \
    USER="$USER" \
    GROUP="$GROUP" \
    PUID="$PUID" \
    PGID="$PGID"

ENV DISPLAY=:99

COPY files/patch.c /

RUN set -x && \
    dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y bash curl unrar gcc libc6-dev-i386 xvfb wine32 && \
    mkdir -p /opt /farcry2 && \
    curl -sSL "https://static3.cdn.ubi.com/far_cry_2/FarCry2_Dedicated_Server_Linux.tar.gz" -o "$ARCHIVE_LINUX" && \
    echo "$CHECKSUM_LINUX $ARCHIVE_LINUX" | sha256sum -c || \
    (sha256sum $ARCHIVE_LINUX && file $ARCHIVE_LINUX && exit 1) && \
    cd /opt && \
    tar xzf "$ARCHIVE_LINUX" --directory . && \
    rm "$ARCHIVE_LINUX" && \
    mv FarCry2_Dedicated_Server_Linux farcry2 && \
    cd farcry2 && \
    mv data_linux Data_Win32 && \
    cd bin && \
    curl -sSL "https://static3.cdn.ubi.com/far_cry_2/FC2ServerLauncher_103_R2.rar" -o "$ARCHIVE_WIN32" && \
    unrar e -o+ "$ARCHIVE_WIN32" && \
    rm "$ARCHIVE_WIN32" && \
    gcc /patch.c -shared -fPIC -ldl -o /opt/farcry2/bin/patch.so -m32 && \
    rm /patch.c && \
    apt-get purge -y curl unrar gcc libc6-dev-i386 && \
    apt-get autoremove -y --purge && \
    chmod ugo=rwx /opt/farcry2 && \
    groupadd -g "$PGID" "$GROUP" && \
    useradd -u "$PUID" -g "$GROUP" -s /bin/sh "$USER" && \
    chown -R "$USER":"$GROUP" /opt/farcry2 /farcry2

COPY files/ /

VOLUME /farcry2

EXPOSE 9000-9003/udp 9000-9003/tcp

ENTRYPOINT ["/docker-entrypoint.sh"]
