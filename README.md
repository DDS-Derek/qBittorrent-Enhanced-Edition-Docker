# qBittorrent-Enhanced-Edition-Docker

[![Build & Release](https://github.com/DDS-Derek/qBittorrent-Enhanced-Edition-Docker/actions/workflows/build.yml/badge.svg)](https://github.com/DDS-Derek/qBittorrent-Enhanced-Edition-Docker/actions/workflows/build.yml) [![Docker Docs](https://github.com/DDS-Derek/qBittorrent-Enhanced-Edition-Docker/actions/workflows/docker_docs.yml/badge.svg)](https://github.com/DDS-Derek/qBittorrent-Enhanced-Edition-Docker/actions/workflows/docker_docs.yml)

由 nevinee 大佬的 qBittorrent 镜像改编的 qBittorrent Enhanced Edition 镜像，使用方法参考原镜像。

## 部署

**qBittorrent Enhanced Edition**

```yaml
version: "2.0"
services:
  qbittorrentee:
    image: ddsderek/qbittorrentee:latest
    container_name: qbittorrentee
    restart: always
    tty: true
    network_mode: bridge
    hostname: qbittorrentee
    volumes:
      - ./data:/data      # 配置保存目录
    tmpfs:
      - /tmp
    environment:          # 下面未列出的其他环境变量请根据环境变量清单自行添加
      - WEBUI_PORT=8080   # WEBUI控制端口，可自定义
      - BT_PORT=34567     # BT监听端口，可自定义
      - PUID=1000         # 输入id -u可查询，群晖必须改
      - PGID=100          # 输入id -g可查询，群晖必须改
    ports:
      - 8080:8080        # 冒号左右一致，必须同WEBUI_PORT一样，本文件中的3个8080要改一起改
      - 34567:34567      # 冒号左右一致，必须同BT_PORT一样，本文件中的5个34567要改一起改
      - 34567:34567/udp  # 冒号左右一致，必须同BT_PORT一样，本文件中的5个34567要改一起改
    #security_opt:       # armv7设备请解除本行和下一行的注释
      #- seccomp=unconfined
```

**qBittorrent Enhanced Edition + IYUU**

```yaml
version: "2.0"
services:
  qbittorrentee:
    image: ddsderek/qbittorrentee:latest-iyuu
    container_name: qbittorrentee
    restart: always
    tty: true
    network_mode: bridge
    hostname: qbittorrentee
    volumes:
      - ./data:/data      # 配置保存目录
    tmpfs:
      - /tmp
    environment:          # 下面未列出的其他环境变量请根据环境变量清单自行添加
      - WEBUI_PORT=8080   # WEBUI控制端口，可自定义
      - BT_PORT=34567     # BT监听端口，可自定义
      - PUID=1000         # 输入id -u可查询，群晖必须改
      - PGID=100          # 输入id -g可查询，群晖必须改
    ports:
      - 8080:8080        # 冒号左右一致，必须同WEBUI_PORT一样，本文件中的3个8080要改一起改
      - 34567:34567      # 冒号左右一致，必须同BT_PORT一样，本文件中的5个34567要改一起改
      - 34567:34567/udp  # 冒号左右一致，必须同BT_PORT一样，本文件中的5个34567要改一起改
    #security_opt:       # armv7设备请解除本行和下一行的注释
      #- seccomp=unconfined
```