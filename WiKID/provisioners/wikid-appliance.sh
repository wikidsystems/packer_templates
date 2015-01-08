history -c
mv -f /root/rpms/motd /etc/
mkdir /root/.ssh
#cp /root/rpms/authorized_keys /root/.ssh/authorized_keys
rm /root/.ssh/authorized_keys
sudo yum -y update
sudo yum install -y java-1.6.0-openjdk postgresql postgresql-libs postgresql-jdbc postgresql-server postgresql-pl compat-libstdc++-296.i686 ntp system-config-date perl-libwww-perl mlocate vim rsync
service postgresql initdb
mkdir -p /opt/WiKID/conf
echo "appliance" > /opt/WiKID/conf/mode.conf
rpm -ivh --nodeps /root/rpms/wikid-*
#mv /root/rpms/security /etc/security
