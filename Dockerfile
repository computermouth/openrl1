FROM debian:trixie-slim

ADD https://github.com/LeonBlade/xnbcli/releases/download/v1.0.7/xnbcli-linux.zip /opt/xnbcli.zip

RUN apt update \
	&& apt install -y make jq imagemagick unzip \
	&& unzip -d /opt /opt/xnbcli.zip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV PATH="$PATH:/opt"
