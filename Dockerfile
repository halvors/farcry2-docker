FROM ubuntu:18.04

# Let apt-get know we are running in noninteractive mode
ENV DEBIAN_FRONTEND=noninteractive

ENV DOWNLOAD_URL=https://static3.cdn.ubi.com/far_cry_2/FarCry2_Dedicated_Server_Linux.tar.gz \
    ARCHIVE_FILE=/tmp/FarCry2_Dedicated_Server_Linux.tar.gz \
    SHA256SUM=281e69fc0cccfa4760ba8db3b82315f52d2f090d9d921dc3adc89afbf046898a

RUN apt-get update && \
    apt-get install -y curl

# Enable 32-bit architecture for 64-bit systems.
RUN dpkg --add-architecture i386

RUN apt-get install -y lib32stdc++6

RUN mkdir -p /opt /farcry2 && \
    curl -sSL "$DOWNLOAD_URL" -o "$ARCHIVE_FILE"

RUN echo "$SHA256  $ARCHIVE_FILE" | sha256sum -c || \
    (sha256sum "$ARCHIVE_FILE" && file "$ARCHIVE_FILE" && exit 1) && \
    tar xzf "$ARCHIVE_FILE" --directory /opt && \
    chmod ugo=rwx /opt/farcry2 && \
    && rm "$ARCHIVE_FILE"

VOLUME /farcry2
 
EXPOSE 9000-9004/udp 9000-9004/tcp

COPY files/ /

ENTRYPOINT ["/docker-entrypoint.sh"]
