FROM frolvlad/alpine-glibc:alpine-3.9

LABEL maintainer="https://github.com/halvors/farcry2-docker"

ARG USER=farcry2
ARG GROUP=farcry2
ARG PUID=845
ARG PGID=845

ENV SHA256=281e69fc0cccfa4760ba8db3b82315f52d2f090d9d921dc3adc89afbf046898a \
    PUID="$PUID" \
    PGID="$PGID"

RUN set -ox pipefail && \
    url="https://static3.cdn.ubi.com/far_cry_2/FarCry2_Dedicated_Server_Linux.tar.gz" && \
    archive="/tmp/FarCry2_Dedicated_Server_Linux.tar.gz" && \
    directory="/opt/FarCry2_Dedicated_Server_Linux" && \
    mkdir -p /opt /farcry2 && \
    apk add --update --no-cache --no-progress bash binutils curl file gettext jq libintl pwgen shadow su-exec && \
    curl -sSL "$url" -o "$archive" && \
    echo "$SHA256  $archive" | sha256sum -c || \
    (sha256sum  "$ARCHIVE_FILE" && file "$ARCHIVE_FILE" && exit 1) && \
    tar xzf "$archive" --directory /opt && \
    mv $directory /opt/farcry2 && \
    chmod ugo=rwx /opt/farcry2 && \
    rm "$archive" && \
    addgroup -g "$PGID" -S "$GROUP" && \
    adduser -u "$PUID" -G "$GROUP" -s /bin/sh -SDH "$USER" && \
    chown -R "$USER":"$GROUP" /opt/farcry2 /farcry2

VOLUME /farcry2
 
EXPOSE 9000-9003/udp 9000-9003/tcp

COPY files/ /

ENTRYPOINT ["/docker-entrypoint.sh"]
