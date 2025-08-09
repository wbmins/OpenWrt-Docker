mkdir -p /var/lock

###############################仅针对旁路由设置###############################
# Disable IPv6
/etc/init.d/odhcpd disable
echo 'net.ipv6.conf.all.disable_ipv6 = 1' >> /etc/sysctl.conf

# 取消 lan 动态 DHCP
uci set dhcp.lan.dynamicdhcp='0'
# 禁用 IPv6 https://www.cnblogs.com/NueXini/p/15707858.html
uci delete dhcp.lan.dhcpv6
uci delete dhcp.lan.ra
uci delete dhcp.lan.ra_slaac
uci delete dhcp.lan.ra_flags
uci set dhcp.@dnsmasq[0].filter_aaaa='1'
# 取消 DNS 缓存
uci set dhcp.@dnsmasq[0].cachesize='0'
# 时区设置
uci set system.@system[0].zonename='Asia/Shanghai'
# 保存到文件
uci commit
###############################仅针对旁路由设置###############################

# Failed to source defaults.vim
cat /usr/share/vim/vimrc | tee /usr/share/vim/defaults.vim

# Add alias command
cat <<EOF | tee -a /etc/profile
alias la='lsd -lah'
alias ua="opkg update && opkg list-upgradable | cut -f 1 -d ' ' | xargs -r opkg upgrade"
EOF

# Install nikki
wget -O - https://github.com/nikkinikki-org/OpenWrt-nikki/raw/refs/heads/main/feed.sh | ash
opkg update
opkg install luci-i18n-nikki-zh-cn

# Change tuna feeds
sed -i 's_https\?://downloads.openwrt.org_https://mirrors.tuna.tsinghua.edu.cn/openwrt_' /etc/opkg/distfeeds.conf

# Clean up temporary files
find /tmp /var -type f ! -name 'resolv.conf' -exec rm -f {} +