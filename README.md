[![Docker Images](https://github.com/wbmins/OpenWrt-Docker/actions/workflows/build_docker_images.yml/badge.svg)](https://github.com/wbmins/OpenWrt-Docker/actions/workflows/build_docker_images.yml)
[![Docker Pulls](https://img.shields.io/docker/pulls/wbmins/openwrt.svg?label=Docker%20Pulls&logo=docker&color=orange)](https://hub.docker.com/r/wbmins/openwrt)
<details>
   <summary>使用方法</summary>
  
1、打开网卡混杂模式，其中enp1s0根据ifconfig命令找到自己的本地网卡名称替换
```
sudo ip link set enp1s0 promisc on
```
2、docker-compose 启动
```yaml
services:
  openwrt:
    image:  wbmins/openwrt:x86_64  
    container_name: openwrt
    privileged: true
    restart: always
    networks:
      - macnet

# docker network create -d macvlan --subnet=192.168.1.0/24 --gateway=192.168.1.1 -o parent=enp1s0 maclan
networks:
  macnet:
    driver: macvlan
    name: macnet
    driver_opts:
      parent: enp1s0 # 第一步的网卡
    ipam:
      config:
        - subnet: 192.168.1.0/24 #子网网段
          gateway: 192.168.1.1 #网关
```

3、修改网络配置并重启网络
```
docker exec openwrt sh -c "
#填写IP地址
uci set network.lan.ipaddr='192.168.1.2'
#填写子网掩码
uci set network.lan.netmask='255.255.255.0'
#填写网关
uci set network.lan.gateway='192.168.1.1'
#填写DNS服务器
uci set network.lan.dns='192.168.1.1'
uci commit
#重启网络
/etc/init.d/network restart
"
```
</details>

<details>
   <summary>容器代理</summary>

|名字|	ip	|接口|
| ----------- | ----------- |----------- |
|宿主机|	192.168.1.4|	enp1s0|
|Openwrt 容器|	192.168.1.5|	macvlan|

1、创建桥接 br-macvlan 网络 `ip link add br-macvlan link enp1s0 type macvlan mode bridge`

2、br-macvlan 网络指定 ip `ip addr add 192.168.1.111 dev br-macvlan`

3、启用 br-macvlan 网络 `ip link set br-macvlan up`

4、让 Openwrt 容器网络经过 br-macvlan `ip route add 192.168.1.5 dev br-macvlan`

5、容器启动指定代理 `-e http_proxy=http://192.168.1.5:7890 -e https_proxy=http://192.168.1.5:7890`

6、上述配置重启后失效，如果需要可以写一个脚本开机自启设置

7、参考
  - [macvlan网络模式下容器与宿主机互通](https://rehtt.com/index.php/archives/236/)
  - [Docker 部署的 openWrt 软路由, 并解决无法与宿主机通信问题](https://www.treesir.pub/post/n1-docker)
</details>

<details>
   <summary>特别鸣谢</summary>

- [zzsrv/OpenWrt-Docker](https://github.com/zzsrv/OpenWrt-Docker)
- [SuLingGG/OpenWrt-Docker](https://github.com/SuLingGG/OpenWrt-Docker)
- [ImmortalWrt OpenWrt Source](https://github.com/immortalwrt/immortalwrt)
- [P3TERX/Actions-OpenWrt](https://github.com/P3TERX/Actions-OpenWrt)
- [OpenWrt Source Repository](https://github.com/openwrt/openwrt)
- [Lean's OpenWrt source](https://github.com/coolsnowwolf/lede)
</details>
