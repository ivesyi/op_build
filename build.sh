#!/bin/bash

# 询问用户输入新的 IPV6_SUBNET 值
echo "请输入新的 IPV6_SUBNET 值:"
read NEW_IPV6_SUBNE

# 询问用户输入token
echo "请输入哪吒监控的token:"
read TOKEN

# 安装BBR
wget --no-check-certificate -O /opt/bbr.sh https://github.com/teddysun/across/raw/master/bbr.sh
chmod 755 /opt/bbr.sh
/opt/bbr.sh

# 下载并执行 nezha.sh 脚本
curl -L https://raw.githubusercontent.com/naiba/nezha/master/script/install.sh -o nezha.sh && chmod +x nezha.sh && sudo ./nezha.sh install_agent nezha.human-ai.com.cn 443 $TOKEN --tls

# 检查 /root/Documents 目录是否存在，如果不存在则创建
if [ ! -d "/root/Documents" ]; then
    mkdir -p /root/Documents
fi

# 切换到 /root 目录
cd /root

# 克隆项目到 /root/Documents 目录，注意使用 --depth 1 来减少克隆的数据量
# 并且使用 git clone 的参数 --no-checkout 和 'git -C' 命令来指定目录
git clone --depth 1 https://github.com/jiangbo212/chrome-driver-rust-auto.git /root/Documents_temp
mv /root/Documents_temp/* /root/Documents/
rm -rf /root/Documents_temp

# 解压 chrome-driver-rust.zip
unzip /root/Documents/chrome-driver-rust.zip -d /root/Documents

# 解压 libcurl-impersonate-v0.6.1.x86_64-linux-gnu.tar.gz
tar -xzf /root/Documents/libcurl/libcurl-impersonate-v0.6.1.x86_64-linux-gnu.tar.gz -C /root/Documents/libcurl

# 替换 /root/Documents/MULTI_ITEMS/.env 文件中的 IPV6_SUBNET 值
sed -i "s/^IPV6_SUBNET=.*/IPV6_SUBNET=${NEW_IPV6_SUBNET}/" /root/Documents/MULTI_ITEMS/.env

ip route add local $NEW_IPV6_SUBNET dev eth0
sysctl net.ipv6.ip_nonlocal_bind=1

# 切换到 /root/Documents/python 目录
cd /root/Documents/python

# 安装 redis python3
sudo apt update
sudo apt install -y redis python3.10-venv

# 创建并激活虚拟环境
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

# 在后台运行 PurchaseCommand3.py 脚本，并将输出重定向到 out.log
nohup python PurchaseCommand3.py > out.log &

# 为shell赋权
chmod +x /root/Documents/monitor.sh
chmod +x /root/Documents/MULTI_ITEMS/start.sh

# 启动rust
/root/Documents/MULTI_ITEMS/start.sh

# 添加crontab任务
(crontab -l 2>/dev/null; echo "*/10 * * * * /root/Documents/monitor.sh") | crontab -