FROM ubuntu:20.04

LABEL maintainer="https://github.com/halvors/farcry2-docker"

ARG DEBIAN_FRONTEND=noninteractive

ARG USER=farcry2 \
    GROUP=farcry2 \
    PUID=845 \
    PGID=845 \
    PORT=9000

ENV CHECKSUM_LINUX="281e69fc0cccfa4760ba8db3b82315f52d2f090d9d921dc3adc89afbf046898a" \
    CHECKSUM_WIN32="714b855adadfaf4773affd74be3e70f9df679293504ca06e6e0b54d2205eb6c0" \
    ARCHIVE_LINUX="FarCry2_Dedicated_Server_Linux.tar.gz" \
    ARCHIVE_WIN32="FC2ServerLauncher_103_R2.rar" \
    USER="$USER" \
    GROUP="$GROUP" \
    PUID="$PUID" \
    PGID="$PGID" \
    PORT="$PORT"

RUN set -x && \
    dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get upgrade -y && \
#   wine
    apt-get install -y curl unar sudo xvfb && \
    mkdir -p /opt /farcry2/{config,logs,maps} && \
    curl -sSL "https://static3.cdn.ubi.com/far_cry_2/$ARCHIVE_LINUX" -o "/tmp/$ARCHIVE_LINUX" && \
    echo "$CHECKSUM_LINUX /tmp/$ARCHIVE_LINUX" | sha256sum -c || \
    (sha256sum "/tmp/$ARCHIVE_LINUX" && file "/tmp/$ARCHIVE_LINUX" && exit 1) && \
    cd /opt && \
    tar xzf "/tmp/$ARCHIVE_LINUX" --directory . && \
    rm "/tmp/$ARCHIVE_LINUX" && \
    mv "${ARCHIVE_LINUX%%.*}" farcry2 && \
    cd farcry2 && \
    mv data_linux Data_Win32 && \
    cd bin && \
    rm FarCry2_server && \
    curl -sSL "https://static3.cdn.ubi.com/far_cry_2/$ARCHIVE_WIN32" -o "/tmp/$ARCHIVE_WIN32" && \
    echo "$CHECKSUM_WIN32 /tmp/$ARCHIVE_WIN32" | sha256sum -c || \
    (sha256sum "/tmp/$ARCHIVE_WIN32" && file "/tmp/$ARCHIVE_WIN32" && exit 1) && \
    unar -q -D "/tmp/$ARCHIVE_WIN32" && \
    rm "/tmp/$ARCHIVE_WIN32" && \
    apt-get purge -y curl unar && \
    apt-get autoremove -y --purge

RUN set -x && \
    apt-get install -y software-properties-common wget && \
    wget -nc https://dl.winehq.org/wine-builds/winehq.key && \
    apt-key add winehq.key && \
    add-apt-repository -y 'deb https://dl.winehq.org/wine-builds/ubuntu/ focal main' && \
    apt-get update && \
    apt-get install -y --install-recommends winehq-staging

RUN set -x && \
    apt-get install -y gcc libc6-dev-i386
#    gcc /patch.c -shared -fPIC -ldl -o /opt/farcry2/bin/patch.so -m32 && \
#    rm /patch.c && \
#    apt-get purge -y gcc libc6-dev-i386 && \
#    apt-get autoremove -y --purge

COPY files/patch.c /

RUN set -x && \
    gcc /patch.c -shared -fPIC -ldl -o /opt/farcry2/bin/patch.so -m32 && \
    rm /patch.c

RUN set -x && \
    groupadd -g "$PGID" "$GROUP" && \
    useradd -u "$PUID" -g "$GROUP" -s /bin/sh -m "$USER" && \
    chown -R "$USER":"$GROUP" /opt/farcry2 /farcry2

COPY files/ /

VOLUME /farcry2
EXPOSE 9000-9003/udp 9000-9003/tcp
ENTRYPOINT ["/docker-entrypoint.sh"]
