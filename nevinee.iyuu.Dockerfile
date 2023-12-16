ARG QB_TAG
FROM ddsderek/qbittorrentee:${QB_TAG}
ENV IYUU_REPO_URL=https://gitee.com/ledc/iyuuplus.git
RUN apk add --no-cache \
       composer \
       git \
       libressl \
       tar \
       unzip \
       zip \
       php81 \
       php81-curl \
       php81-dom \
       php81-json \
       php81-mbstring \
       php81-openssl \
       php81-opcache \
       php81-pdo \
       php81-pdo_sqlite \
       php81-phar \
       php81-pcntl \
       php81-posix \
       php81-simplexml \
       php81-sockets \
       php81-session \
       php81-zip \
       php81-zlib \
       php81-xml \
    && git config --global pull.ff only \
    && git config --global --add safe.directory /iyuu \
    && git clone --depth 1 https://github.com/ledccn/IYUUPlus.git /iyuu \
    && echo -e "upload_max_filesize=100M\npost_max_size=108M\nmemory_limit=1024M\ndate.timezone=${TZ}" > /etc/php81/conf.d/99-overrides.ini \
    && rm -rf /var/cache/apk/* /tmp/*
COPY root2 /
VOLUME ["/iyuu"]