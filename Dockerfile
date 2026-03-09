FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    lib32gcc-s1 lib32stdc++6 libicu-dev curl ca-certificates gosu unzip \
    && rm -rf /var/lib/apt/lists/*

RUN curl -L https://github.com/gorcon/rcon-cli/releases/download/v0.10.3/rcon-0.10.3-amd64_linux.tar.gz -o rcon-cli.tar.gz \
    && tar xzvf rcon-cli.tar.gz \
    && mv rcon-0.10.3-amd64_linux rcon-cli \
    && mv rcon-cli /usr/local/bin/rcon-cli \
    && chmod +x /usr/local/bin/rcon-cli \
    && rm rcon-cli.tar.gz

# CRUCIAL : On pré-crée TOUS les dossiers Steam possibles
RUN mkdir -p /home/steam/steamcmd /home/steam/nightingale-server /home/steam/Steam /home/steam/.steam

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
