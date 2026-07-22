FROM alpine:3.24 AS builder
RUN apk upgrade \
    && apk add --no-cache \
       boost-dev \
       cmake \
       curl \
       g++ \
       libtorrent-rasterbar-dev \
       openssl-dev \
       patch \
       qt6-qtbase-dev \
       qt6-qtbase-private-dev \
       qt6-qttools-dev \
       samurai \
       tar \
       zlib-dev \
    && rm -rf /tmp/* /var/cache/apk/*
ARG QBITTORRENTEE_VERSION
RUN mkdir -p /tmp/qbittorrent \
    && cd /tmp/qbittorrent \
    && curl -sSL https://github.com/c0re100/qBittorrent-Enhanced-Edition/archive/refs/tags/release-${QBITTORRENTEE_VERSION}.tar.gz | tar xz --strip-components 1 \
    && cmake \
       -D CMAKE_BUILD_TYPE=Release \
       -D GUI=OFF \
       -D WEBUI=ON \
       -D STACKTRACE=OFF \
       -B release \
       -G Ninja \
    && cmake --build release -j $(nproc) \
    && cmake --install release \
    && ls -al /usr/local/bin/ \
    && qbittorrent-nox --help \
    && qbittorrent-nox --version
RUN echo "Copy to /out" \
    && strip /usr/local/bin/qbittorrent-nox \
    && mkdir -p /out/usr/bin \
    && cp /usr/local/bin/qbittorrent-nox /out/usr/bin
RUN echo "Write dependency version" \
    && apk update \
    && OpenSSL=$(apk version openssl-dev | sed -n '2p' | awk -F'= ' '{print $2}' | awk -F'-' '{print $1}') \
    && Boost=$(apk version boost-dev | sed -n '2p' | awk -F'= ' '{print $2}' | awk -F'-' '{print $1}') \
    && Libtorrent=$(apk version libtorrent-rasterbar-dev | sed -n '2p' | awk -F'= ' '{print $2}' | awk -F'-' '{print $1}') \
    && Qt=$(apk version qt6-qtbase-dev | sed -n '2p' | awk -F'= ' '{print $2}' | awk -F'-' '{print $1}') \
    && zlib=$(apk version zlib | sed -n '2p' | awk -F'= ' '{print $2}' | awk -F'-' '{print $1}') \
    && echo -e '{\n    "OpenSSL": "'$OpenSSL'",\n    "Boost": "'$Boost'",\n    "Libtorrent": "'$Libtorrent'",\n    "Qt": "'$Qt'",\n    "zlib": "'$zlib'"\n}' \
    && echo -e '{\n    "OpenSSL": "'$OpenSSL'",\n    "Boost": "'$Boost'",\n    "Libtorrent": "'$Libtorrent'",\n    "Qt": "'$Qt'",\n    "zlib": "'$zlib'"\n}' > /out/usr/bin/dependency-version.json \
    && rm -rf /tmp/* /var/cache/apk/*

FROM alpine:3.24 AS app
ENV QBT_PROFILE=/home/qbittorrent \
    TZ=Asia/Shanghai \
    PUID=1000 \
    PGID=100 \
    WEBUI_PORT=8080 \
    BT_PORT=34567 \
    LANG=zh_CN.UTF-8 \
    SHELL=/bin/bash \
    PS1="\u@\h:\w \$ "
RUN apk upgrade \
    && apk add --no-cache \
       bash \
       busybox-suid \
       curl \
       jq \
       libtorrent-rasterbar \
       openssl \
       qt6-qtbase \
       qt6-qtbase-sqlite \
       shadow \
       su-exec \
       tini \
       tzdata \
    && rm -rf /tmp/* /var/cache/apk/* \
    && ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo "${TZ}" > /etc/timezone \
    && useradd qbittorrent -u ${PUID} -U -m -d ${QBT_PROFILE} -s /sbin/nologin \
    && sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories
COPY --from=builder /out /
COPY root /
WORKDIR /data
VOLUME ["/data"]
ENTRYPOINT ["tini", "-g", "--", "entrypoint.sh"]
