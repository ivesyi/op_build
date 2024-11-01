#!/bin/bash


echo "请输入新的 IPV6_SUBNET 值:"
read NEW_IPV6_SUBNET

# github access token
echo "请输入GITHUB access token:"
read ACCESS_TOKEN

# 提示用户输入选择，并读取输入
echo "请选择要执行的start脚本，从1到9。默认为1："
read -r choice

# 验证输入是否为空或者不在1-9之间，如果是，则设置默认值1
if [[ -z "$choice" ]] || [[ ! "$choice" =~ ^[1-9]$ ]]; then
    choice=1
fi

# 安装BBR
wget --no-check-certificate -O /opt/bbr.sh https://github.com/teddysun/across/raw/master/bbr.sh
chmod 755 /opt/bbr.sh
/opt/bbr.sh

# 检查 /root/Documents 目录是否存在，如果不存在则创建
if [ ! -d "/root/Documents" ]; then
    mkdir -p /root/Documents
fi

# 切换到 /root 目录
cd /root

# 克隆项目到 /root/Documents 目录，注意使用 --depth 1 来减少克隆的数据量
# 并且使用 git clone 的参数 --no-checkout 和 'git -C' 命令来指定目录
git clone --depth 1 https://oauth2:${ACCESS_TOKEN}@github.com/jiangbo212/chrome-driver-rust-auto.git /root/Documents_temp
mv /root/Documents_temp/* /root/Documents/
rm -rf /root/Documents_temp

# 安装unzip
sudo apt update
apt-get install unzip

# 解压 chrome-driver-rust.zip
unzip /root/Documents/chrome-driver-rust.zip -d /root/Documents

# 解压 libcurl-impersonate-v0.6.1.x86_64-linux-gnu.tar.gz
mkdir -p /opt/libcurl && tar -xzf /root/Documents/libcurl/libcurl-impersonate-v0.6.1.x86_64-linux-gnu.tar.gz -C /opt/libcurl

# 替换 /root/Documents/MULTI_ITEMS/.env 文件中的 IPV6_SUBNET 值
sed -i "s|^IPV6_SUBNET=.*|IPV6_SUBNET=${NEW_IPV6_SUBNET}|" /root/Documents/MULTI_ITEMS/.env

ip route add local $NEW_IPV6_SUBNET dev eth0
sysctl net.ipv6.ip_nonlocal_bind=1

# 切换到 /root/Documents/python 目录
cd /root/Documents/python

# 安装 redis python3
sudo apt install -y redis python3.10-venv

# 创建并激活虚拟环境
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

# 在后台运行 PurchaseCommand3.py 脚本，并将输出重定向到 out.log
nohup python PurchaseCommand3.py > out.log &
python test.py

# 根据选择强制移动相应的脚本，替换已存在的文件
mv -f "/root/Documents/MULTI_ITEMS/start${choice}.sh" "/root/Documents/MULTI_ITEMS/start.sh"
echo "已选择并移动start${choice}.sh为start.sh"

# 为shell赋权
chmod +x /root/Documents/chrome-driver-rust
chmod +x /root/Documents/monitor.sh
chmod +x /root/Documents/MULTI_ITEMS/start.sh

# 启动rust
cd /root/Documents/MULTI_ITEMS && ./start.sh

# 添加crontab任务
(crontab -l 2>/dev/null; echo "*/10 * * * * /root/Documents/monitor.sh") | crontab -
