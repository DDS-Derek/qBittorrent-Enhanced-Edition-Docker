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
       php82 \
       php82-curl \
       php82-dom \
       php82-json \
       php82-mbstring \
       php82-openssl \
       php82-opcache \
       php82-pdo \
       php82-pdo_sqlite \
       php82-phar \
       php82-pcntl \
       php82-posix \
       php82-simplexml \
       php82-sockets \
       php82-session \
       php82-zip \
       php82-zlib \
       php82-xml \
    && git config --global pull.ff only \
    && git config --global --add safe.directory /iyuu \
    && git clone --depth 1 https://github.com/ledccn/IYUUPlus.git /iyuu \
    && echo -e "upload_max_filesize=100M\npost_max_size=108M\nmemory_limit=1024M\ndate.timezone=${TZ}" > /etc/php82/conf.d/99-overrides.ini \
    && rm -rf /var/cache/apk/* /tmp/*
COPY root2 /
VOLUME ["/iyuu"]