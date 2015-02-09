history -c
mv -f /root/files/motd /etc/
mkdir /root/.ssh
#cp /root/files/authorized_keys /root/.ssh/authorized_keys
rm /root/.ssh/authorized_keys
sudo yum -y update
sudo yum install -y java-1.6.0-openjdk postgresql postgresql-libs postgresql-jdbc postgresql-server postgresql-pl compat-libstdc++-296 ntp system-config-date perl-libwww-perl mlocate vim rsync
service postgresql initdb
mkdir -p /opt/WiKID/conf
echo "appliance" > /opt/WiKID/conf/mode.conf
yum -y install --nogpg /root/files/wikid-*
#mv /root/files/security /etc/security
