ARG VERSION
ARG REPO_NAME
FROM ${REPO_NAME}:${VERSION}
ENV IYUU_REPO_URL=https://gitee.com/ledc/iyuuplus.git
RUN apk add --no-cache \
       composer \
       git \
       libressl \
       tar \
       unzip \
       zip \
       php83 \
       php83-curl \
       php83-dom \
       php83-json \
       php83-mbstring \
       php83-openssl \
       php83-opcache \
       php83-pdo \
       php83-pdo_sqlite \
       php83-phar \
       php83-pcntl \
       php83-posix \
       php83-simplexml \
       php83-sockets \
       php83-session \
       php83-zip \
       php83-zlib \
       php83-xml \
    && git config --global pull.ff only \
    && git config --global --add safe.directory /iyuu \
    && git clone --depth 1 https://github.com/ledccn/IYUUPlus.git /iyuu \
    && echo -e "upload_max_filesize=100M\npost_max_size=108M\nmemory_limit=1024M\ndate.timezone=${TZ}" > /etc/php83/conf.d/99-overrides.ini \
    && rm -rf /var/cache/apk/* /tmp/*
COPY root2 /
VOLUME ["/iyuu"]
