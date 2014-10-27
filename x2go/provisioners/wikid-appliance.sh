history -c
mv -f /root/rpms/motd /etc/
#sudo yum -y update
sudo yum install -y java-1.6.0-openjdk postgresql postgresql-libs postgresql-jdbc postgresql-server postgresql-pl compat-libstdc++-296 ntp system-config-date perl-libwww-perl mlocate
service postgresql initdb
mkdir -p /opt/WiKID/conf
echo "appliance" > /opt/WiKID/conf/mode.conf
#yum -y install --nogpg /root/rpms/wikid-*

