yum -y update
cp  /root/rpms/pam_radius_auth.so /usr/lib64/security/
mkdir /etc/raddb/
cp /root/rpms/server /etc/raddb/	
cp /root/rpms/openvpn /etc/pam.d/
wget http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-1.noarch.rpm
rpm -Uvh /root/rpms/epel-release-7-1.noarch.rpm
yum -y install openvpn easy-rsa
cp /root/rpms/server.conf /etc/openvpn


mkdir -p /etc/openvpn/easy-rsa/keys

cp /usr/share/easy-rsa/2.0/* /etc/openvpn/easy-rsa/

cp /root/rpms/vars /etc/openvpn/easy-rsa/


cd /etc/openvpn/easy-rsa/

source ./vars

./clean-all

./build-ca --batch

./build-key-server --batch server

./build-dh 

./build-key --batch client

./build-key --batch client2

cp /etc/openvpn/easy-rsa/keys/dh2048.pem /etc/openvpn
rm /etc/openvpn/ca.crt
cp /etc/openvpn/easy-rsa/keys/ca.crt /etc/openvpn
rm /etc/openvpn/server.crt
cp /etc/openvpn/easy-rsa/keys/server.crt /etc/openvpn
rm /etc/openvpn/server.key
cp /etc/openvpn/easy-rsa/keys/server.key /etc/openvpn

# commented for centos 6 on amazon
#firewall-cmd --add-service openvpn
#firewall-cmd --permanent --add-service openvpn
#firewall-cmd --add-masquerade
#firewall-cmd --permanent --add-masquerade
#systemctl start openvpn@server.service
#systemctl enable openvpn@server.service

service openvpn start
chkconfig openvpn on

# Disable IPv6 to stop DNS leakage on OpenVPN

echo 'net.ipv6.conf.all.disable_ipv6 = 1' >> /etc/sysctl.conf
echo 'net.ipv6.conf.default.disable_ipv6 = 1' >> /etc/sysctl.conf
