FROM ubuntu:20.04

ENV TARSNAP_VERSION 1.0.40
ENV TARSNAP_SHA256 bccae5380c1c1d6be25dccfb7c2eaa8364ba3401aafaee61e3c5574203c27fd5

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /root

ENV BUILD_PACKAGES \
    make \
    gcc \
    libssl-dev \
    zlib1g-dev \
    e2fslibs-dev

ENV APT_PACKAGES \
    wget \
    ca-certificates \
    curl \
    tzdata \
    iproute2 \
    locales \
    openssl \
    wget \
    cron 

# install build and runtime dependencies
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get -y install $APT_PACKAGES $BUILD_PACKAGES && \
# download and verify checksum
    curl https://www.tarsnap.com/download/tarsnap-autoconf-$TARSNAP_VERSION.tgz --output tarsnap.tgz  && \
    export expected_hash=$(sha256sum tarsnap.tgz | awk '{print $1}') && \
    if [ "$expected_hash" != "$TARSNAP_SHA256" ]; then \
        echo "The hash check failed!"; \
        exit 1; \
    fi; \
# compile and install tarsnap
    tar zxf tarsnap.tgz && \
    cd tarsnap-autoconf-$TARSNAP_VERSION && \
    ./configure && \
    make && \
    make install && \
    make clean && \
# clean up
    rm -rf tarsnap* && \
    apt-get -y remove --purge $BUILD_PACKAGES && \
    apt-get -y autoremove && \
    rm -rf /var/lib/apt/lists/*

ADD entrypoint.sh /entrypoint.sh
ADD crontab /var/run/crontab

RUN mkdir -p /var/run/secrets
RUN mkdir -p /cache
RUN mkdir -p /data

# https://mail.tarsnap.com/tarsnap-users/msg00037.html
ENV LC_ALL=C
ENV LANG=C
ENV LANGUAGE=C

RUN dpkg-reconfigure locales


CMD ["bash", "-c", "/entrypoint.sh"]
