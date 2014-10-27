yum -y update
cp  /root/rpms/pam_radius_auth.so /usr/lib64/security/
mkdir /etc/raddb/
cp /root/rpms/server /etc/raddb/	
cp /root/rpms/sshd /etc/pam.d/
wget http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-1.noarch.rpm
rpm -Uvh /root/rpms/epel-release-7-1.noarch.rpm
yum -y install openvpn
cp /root/rpms/server.conf /etc/openvpn
cp  /usr/share/doc/openvpn-2.3.2/sample/sample-keys/* /etc/openvpn
firewall-cmd --add-service openvpn
firewall-cmd --permanent --add-service openvpn
firewall-cmd --add-masquerade
firewall-cmd --permanent --add-masquerade
systemctl start openvpn@server.service
systemctl enable openvpn@server.service
