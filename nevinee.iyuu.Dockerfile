ARG QB_TAG

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

FROM nevinee/qbittorrent:${QB_TAG}-iyuu

COPY --from=Build --chmod=755 /qbittorrent/qbittorrent-nox /usr/bin/qbittorrent-nox
