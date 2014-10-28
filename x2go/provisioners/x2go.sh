yum -y --disablerepo="epel" update
yum clean all

rpm -Uvh http://mirror.us.leaseweb.net/epel/6/x86_64/epel-release-6-8.noarch.rpm
yum -y install x2goserver-xsession vim
yum -y groupinstall "Desktop" "Desktop Platform" "X Window System" "Fonts"
rm -f ~/ssh/authorized_keys


# some centos 7 firewall rules
#firewall-cmd --permanent --zone=public --add-service=ssh
#firewall-cmd --reload

# comment these lines to not install pam_radius for two-factor auth.
cp  /root/rpms/pam_radius_auth.so /lib64/security/
mkdir /etc/raddb/
cp /root/rpms/server /etc/raddb/
#cp /root/rpms/sshd /etc/pam.d/


