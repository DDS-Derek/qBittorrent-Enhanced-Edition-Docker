############### Version ###############
ARG qbitorrent_tag
#######################################

FROM alpine:3.18 AS Build

############### Version ###############
ARG QBEE_TAG
#######################################

WORKDIR /qbittorrent

RUN apk add bash wget curl unzip zip

RUN ARCH=$(uname -m); \
    if [[ ${ARCH} == "x86_64" ]]; \
    then ARCH="qbittorrent-enhanced-nox_x86_64-linux-musl_static.zip"; \
    elif [[ ${ARCH} == "aarch64" ]]; \
    then ARCH="qbittorrent-enhanced-nox_aarch64-linux-musl_static.zip"; \
    elif [[ ${ARCH} == "armv7l" ]]; \
    then ARCH="qbittorrent-enhanced-nox_arm-linux-musleabi_static.zip"; \
    fi && \
    curl -L -o ${PWD}/qbittorrentee.zip https://github.com/c0re100/qBittorrent-Enhanced-Edition/releases/download/release-${QBEE_TAG}/${ARCH} && \
    unzip qbittorrentee.zip

FROM nevinee/qbittorrent:${qbitorrent_tag}

COPY --from=Build --chmod=755 /qbittorrent/qbittorrent-nox /usr/bin/qbittorrent-nox
