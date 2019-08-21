FROM ubuntu:18.04

LABEL maintainer="https://github.com/halvors/farcry2-docker"

ARG USER=farcry2
ARG GROUP=farcry2
ARG PUID=845
ARG PGID=845

ENV SHA256=281e69fc0cccfa4760ba8db3b82315f52d2f090d9d921dc3adc89afbf046898a \
    PUID="$PUID" \
    PGID="$PGID"

# Enable 32-bit architecture for 64-bit systems.
#RUN dpkg --add-architecture i386

RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y curl libc6:i386 libncurses5:i386 libstdc++6:i386 zlib1g:i386

# Install necessary packages.
RUN set -x && \
    apt-get update && \
#    apt-get upgrade -y && \
#    apt-get install -y libc6:i386 libncurses5:i386 libstdc++6:i386 && \
#    apt-get install -y curl lib32stdc++6 lib32z1 lib32ncurses5 libc6-i386 lib32gcc1 && \
    url="https://static3.cdn.ubi.com/far_cry_2/FarCry2_Dedicated_Server_Linux.tar.gz" && \
    archive="/tmp/FarCry2_Dedicated_Server_Linux.tar.gz" && \
    directory="/opt/FarCry2_Dedicated_Server_Linux" && \
    mkdir -p /opt /farcry2 && \
    #apk add --update --no-cache --no-progress bash binutils curl file gettext jq libintl pwgen shadow su-exec libstdc++6 --arch x86 && \
    curl -sSL "$url" -o "$archive" && \
    echo "$SHA256  $archive" | sha256sum -c || \
    (sha256sum  "$ARCHIVE_FILE" && file "$ARCHIVE_FILE" && exit 1) && \
    tar xzf "$archive" --directory /opt && \
    mv $directory /opt/farcry2 && \
    chmod ugo=rwx /opt/farcry2 && \
    rm "$archive" && \
    groupadd -g "$PGID" "$GROUP" && \
    useradd -u "$PUID" -g "$GROUP" -s /bin/sh "$USER" && \
    chown -R "$USER":"$GROUP" /opt/farcry2 /farcry2

VOLUME /farcry2
 
EXPOSE 9000-9003/udp 9000-9003/tcp

COPY files/ /

ENTRYPOINT ["/docker-entrypoint.sh"]
