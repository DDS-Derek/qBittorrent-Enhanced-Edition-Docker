FROM alpine:3.19 AS Build

ARG QBEE_TAG
ARG AMD64_NAME
ARG ARM64V8_NAME
ARG ARMV7_NAME

WORKDIR /qbittorrent

RUN apk add bash wget curl unzip zip jq

RUN ARCH=$(uname -m); \
    if [[ ${ARCH} == "x86_64" ]]; \
    then ARCH=${AMD64_NAME}; \
    elif [[ ${ARCH} == "aarch64" ]]; \
    then ARCH=${ARM64V8_NAME}; \
    elif [[ ${ARCH} == "armv7l" ]]; \
    then ARCH=${ARMV7_NAME}; \
    fi && \
    curl -L -o ${PWD}/qbittorrentee.zip https://github.com/c0re100/qBittorrent-Enhanced-Edition/releases/download/release-${QBEE_TAG}/${ARCH} && \
    unzip qbittorrentee.zip

FROM alpine:3.19
ENV QBT_PROFILE=/home/qbittorrent \
    TZ=Asia/Shanghai \
    PUID=1000 \
    PGID=100 \
    WEBUI_PORT=8080 \
    BT_PORT=34567 \
    QB_USERNAME=admin \
    QB_PASSWORD=adminadmin \
    LANG=zh_CN.UTF-8 \
    SHELL=/bin/bash \
    PS1="\u@\h:\w \$ "
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.bfsu.edu.cn/g' /etc/apk/repositories \
    && apk add --no-cache \
       bash \
       busybox-suid \
       curl \
       jq \
       openssl \
       python3 \
       shadow \
       su-exec \
       tini \
       tzdata \
    && rm -rf /tmp/* /var/cache/apk/* \
    && ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo "${TZ}" > /etc/timezone \
    && useradd qbittorrent -u ${PUID} -U -m -d ${QBT_PROFILE} -s /sbin/nologin
COPY --from=Build --chmod=755 /qbittorrent/qbittorrent-nox /usr/bin/qbittorrent-nox
COPY root /
WORKDIR /data
VOLUME ["/data"]
ENTRYPOINT ["tini", "-g", "--", "entrypoint.sh"]
