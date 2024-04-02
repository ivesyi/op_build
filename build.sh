#!/bin/bash

# ѯ���û������µ� IPV6_SUBNET ֵ
echo "�������µ� IPV6_SUBNET ֵ:"
read NEW_IPV6_SUBNE

# ѯ���û�����token
echo "��������߸��ص�token:"
read TOKEN

# ��װBBR
wget --no-check-certificate -O /opt/bbr.sh https://github.com/teddysun/across/raw/master/bbr.sh
chmod 755 /opt/bbr.sh
/opt/bbr.sh

# ���ز�ִ�� nezha.sh �ű�
curl -L https://raw.githubusercontent.com/naiba/nezha/master/script/install.sh -o nezha.sh && chmod +x nezha.sh && sudo ./nezha.sh install_agent nezha.human-ai.com.cn 443 $TOKEN --tls

# ��� /root/Documents Ŀ¼�Ƿ���ڣ�����������򴴽�
if [ ! -d "/root/Documents" ]; then
    mkdir -p /root/Documents
fi

# �л��� /root Ŀ¼
cd /root

# ��¡��Ŀ�� /root/Documents Ŀ¼��ע��ʹ�� --depth 1 �����ٿ�¡��������
# ����ʹ�� git clone �Ĳ��� --no-checkout �� 'git -C' ������ָ��Ŀ¼
git clone --depth 1 https://github.com/jiangbo212/chrome-driver-rust-auto.git /root/Documents_temp
mv /root/Documents_temp/* /root/Documents/
rm -rf /root/Documents_temp

# ��ѹ chrome-driver-rust.zip
unzip /root/Documents/chrome-driver-rust.zip -d /root/Documents

# ��ѹ libcurl-impersonate-v0.6.1.x86_64-linux-gnu.tar.gz
tar -xzf /root/Documents/libcurl/libcurl-impersonate-v0.6.1.x86_64-linux-gnu.tar.gz -C /root/Documents/libcurl

# �滻 /root/Documents/MULTI_ITEMS/.env �ļ��е� IPV6_SUBNET ֵ
sed -i "s/^IPV6_SUBNET=.*/IPV6_SUBNET=${NEW_IPV6_SUBNET}/" /root/Documents/MULTI_ITEMS/.env

ip route add local $NEW_IPV6_SUBNET dev eth0
sysctl net.ipv6.ip_nonlocal_bind=1

# �л��� /root/Documents/python Ŀ¼
cd /root/Documents/python

# ��װ redis python3
sudo apt update
sudo apt install -y redis python3.10-venv

# �������������⻷��
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

# �ں�̨���� PurchaseCommand3.py �ű�����������ض��� out.log
nohup python PurchaseCommand3.py > out.log &

# Ϊshell��Ȩ
chmod +x /root/Documents/monitor.sh
chmod +x /root/Documents/MULTI_ITEMS/start.sh

# ����rust
/root/Documents/MULTI_ITEMS/start.sh

# ���crontab����
(crontab -l 2>/dev/null; echo "*/10 * * * * /root/Documents/monitor.sh") | crontab -