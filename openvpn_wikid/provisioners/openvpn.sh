sudo yum -y upgrade ca-certificates --disablerepo=epel
cp /root/files/pam_radius_auth.so /usr/lib64/security/
cp /root/files/pam_radius_auth.so /lib64/security/
mkdir /etc/raddb/
cp /root/files/server /etc/raddb/	
cp /root/files/sshd /etc/pam.d/openvpn
#wget http://dl.fedoraproject.org/pub/epel/6/x86_64/e/epel-release-6-8.noarch.rpm
rpm -Uvh /root/files/epel-release-6-8.noarch.rpm
yum clean all
yum -y install openvpn easy-rsa
cp /root/files/server.conf /etc/openvpn


mkdir -p /etc/openvpn/easy-rsa/keys

cp /usr/share/easy-rsa/2.0/* /etc/openvpn/easy-rsa/

cp /root/files/vars /etc/openvpn/easy-rsa/
yum -y update
cp /root/files/pam_radius_auth.so /usr/lib64/security/
cp /root/files/pam_radius_auth.so /lib64/security/
mkdir /etc/raddb/
cp /root/files/server /etc/raddb/	
cp /root/files/sshd /etc/pam.d/openvpn
wget http://dl.fedoraproject.org/pub/epel/6/x86_64/e/epel-release-6-8.noarch.rpm
rpm -Uvh /root/files/epel-release-6-8.noarch.rpm
yum -y install openvpn easy-rsa
cp /root/files/server.conf /etc/openvpn


mkdir -p /etc/openvpn/easy-rsa/keys
cp /usr/share/easy-rsa/2.0/* /etc/openvpn/easy-rsa/
cp /root/files/vars /etc/openvpn/easy-rsa/
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



