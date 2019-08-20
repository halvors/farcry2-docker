FROM ubuntu:18.04

LABEL maintainer="https://github.com/halvors/farcry2-docker"

ARG USER=farcry2
ARG GROUP=farcry2
ARG PUID=845
ARG PGID=845

ENV SHA256=281e69fc0cccfa4760ba8db3b82315f52d2f090d9d921dc3adc89afbf046898a \
    PUID="$PUID" \
    PGID="$PGID"

RUN apt-get update && \
    apt-get install -y curl

# Enable 32-bit architecture for 64-bit systems.
#RUN dpkg --add-architecture i386

#RUN apt-get install -y lib32stdc++6 lib32ncurses5 lib32z1

RUN url="https://static3.cdn.ubi.com/far_cry_2/FarCry2_Dedicated_Server_Linux.tar.gz" && \
    archive="/tmp/FarCry2_Dedicated_Server_Linux.tar.gz" && \
    directory="/opt/FarCry2_Dedicated_Server_Linux" && \
    mkdir -p /opt /farcry2 && \
    curl -sSL "$url" -o "$archive"

RUN archive="/tmp/FarCry2_Dedicated_Server_Linux.tar.gz" && \
    directory="/opt/FarCry2_Dedicated_Server_Linux" && \
    echo "$SHA256  $archive" | sha256sum -c || \
    (sha256sum  "$ARCHIVE_FILE" && file "$ARCHIVE_FILE" && exit 1) && \
    tar xzf "$archive" --directory /opt && \
    mv $directory /opt/farcry2 && \
    chmod ugo=rwx /opt/farcry2 && \
    rm "$archive" && \
    addgroup --gid "$PGID" "$GROUP" && \
    adduser --disabled-login --no-create-home --quiet --uid "$PUID" --gid "$PGID" --shell /bin/sh "$USER" && \
    chown -R "$USER":"$GROUP" /opt/farcry2 /farcry2

VOLUME /farcry2
 
EXPOSE 9000-9003/udp 9000-9003/tcp

COPY files/ /

ENTRYPOINT ["/docker-entrypoint.sh"]
