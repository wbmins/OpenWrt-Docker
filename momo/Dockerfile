FROM wbmins/openwrt

LABEL org.opencontainers.image.authors="wbmins"

ADD https://raw.githubusercontent.com/wbmins/OpenWrt-Docker/refs/heads/main/scripts/custom.sh /tmp/custom.sh

RUN chmod +x /tmp/custom.sh && /tmp/custom.sh momo