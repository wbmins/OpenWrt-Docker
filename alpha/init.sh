mkdir -p /var/lock

# Disable IPv6
/etc/init.d/odhcpd disable
echo 'net.ipv6.conf.all.disable_ipv6 = 1' >> /etc/sysctl.conf

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