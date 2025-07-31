mkdir -p /var/log

# 禁用 IPv6
/etc/init.d/odhcpd disable
echo 'net.ipv6.conf.all.disable_ipv6 = 1' >> /etc/sysctl.conf

# 修复vim编辑提示
cat /usr/share/vim/vimrc | tee /usr/share/vim/defaults.vim

# 安装 nikki
wget -O - https://github.com/nikkinikki-org/OpenWrt-nikki/raw/refs/heads/main/feed.sh | ash
apk add luci-i18n-nikki-zh-cn
service nikki enable

# 增加环境变量
cat <<'EOF' | tee -a /etc/profile
# export http_proxy=http://127.0.0.1:7890
# export https_proxy=$http_proxy
alias la='lsd -lah'
EOF

# 减小镜像体积
find /tmp /var -type f ! -name 'resolv.conf' -exec rm -f {} +