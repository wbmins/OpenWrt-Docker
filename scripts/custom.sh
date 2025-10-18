#!/bin/ash
set -euo pipefail

mkdir -p /var/lock

###############################仅针对旁路由设置###############################
# 禁用 IPv6
/etc/init.d/odhcpd disable
echo 'net.ipv6.conf.all.disable_ipv6 = 1' >> /etc/sysctl.conf

cat <<'EOF' | tee -a /etc/uci-defaults/99-init-settings
# 禁用 lan 动态 DHCP
uci set dhcp.lan.dynamicdhcp='0'
# 禁用 IPv6
uci delete dhcp.lan.dhcpv6
uci delete dhcp.lan.ra
uci delete dhcp.lan.ra_slaac
uci delete dhcp.lan.ra_flags
uci set dhcp.@dnsmasq[0].filter_aaaa='1'
# 禁用 DNS 缓存
uci set dhcp.@dnsmasq[0].cachesize='0'
# 时区设置
uci set system.@system[0].zonename='Asia/Shanghai'
# 保存到文件
uci commit
EOF
###############################仅针对旁路由设置###############################

# 修复 vim 默认配置
cat /usr/share/vim/vimrc | tee /usr/share/vim/defaults.vim

# 添加环境变量和别名
cat <<'EOF' | tee -a /etc/profile
export PS1="\033[1;34m# \033[1;36m\u \033[0m@ \033[1;32m\h \033[0min \033[1;33m\w \033[0m[\$(date +%T)]\n\033[1;31m✦\033[0m "

export http_proxy=http://127.0.0.1:7890
export https_proxy=$http_proxy

alias la='lsd -lah'
alias uu="opkg update && opkg list-upgradable"
alias ua="opkg update && opkg list-upgradable | cut -f 1 -d ' ' | xargs -r opkg upgrade"
EOF

# 安装nikki/momo
if [[ "${1:-}" == "nikki" ]]; then
    wget -O - https://github.com/nikkinikki-org/OpenWrt-nikki/raw/refs/heads/main/feed.sh | ash
    opkg install luci-i18n-nikki-zh-cn
elif [[ "${1:-}" == "momo" ]]; then
    wget -O - https://github.com/nikkinikki-org/OpenWrt-momo/raw/refs/heads/main/feed.sh | ash
    opkg install luci-i18n-momo-zh-cn
    /etc/init.d/sing-box disable

    URL=$(curl -s https://api.github.com/repos/SagerNet/sing-box/releases/latest \
    | jsonfilter -e '@.assets[*].browser_download_url' \
    | grep 'linux-amd64\.tar\.gz' \
    | head -n1)
    FILE=$(basename "$URL")
    curl -L -o "/tmp/$FILE" "$URL"
    tar -xzf "/tmp/$FILE" -C /tmp/ && mv "/tmp/$(tar -tzf "/tmp/$FILE" | head -n1 | cut -f1 -d"/")/sing-box" /usr/bin/
fi

# 修改为科大源
sed -i 's_https\?://downloads.openwrt.org_https://mirrors.ustc.edu.cn/openwrt_' /etc/opkg/distfeeds.conf

# 清理临时文件
find /tmp /var -type f ! -name 'resolv.conf' -exec rm -f {} +
