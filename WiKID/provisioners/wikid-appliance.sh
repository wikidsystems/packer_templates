history -c



sudo mv -f /home/centos/rpms/motd /etc/
#mkdir /root/.ssh
#cp /root/rpms/authorized_keys /root/.ssh/authorized_keys
sudo rm /root/.ssh/authorized_keys
sudo rm /root/.bash_history
sudo rm -Rf /home/centos/.ssh/authorized_keys
rm -Rf /home/centos/.ssh/authorized_keys
#rmdir /home/centos/.ssh
# setup ec2 user

#udo useradd -m -s /bin/bash centos
#mkdir /home/centos/.ssh
sudo chown -R centos:centos /home/centos/.ssh/
sudo \cp -rf /home/centos/rpms/rc.local /etc/
#\cp -rf /root/rpms/S50getsshkey /etc/rc2.d/
sudo chmod -R 0700 /home/centos/.ssh
sudo mkdir /home/centos/tmp

#sudo yum -y update
sudo yum install -y java-1.8.0-openjdk postgresql postgresql-libs postgresql-jdbc postgresql-server postgresql-pl compat-libstdc++-296.i686 ntp system-config-date perl-libwww-perl mlocate vim rsync vim policycoreutils
sudo service postgresql initdb
#sudo chkconfig postgresql on
sudo mkdir -p /opt/WiKID/conf
#sudo echo "appliance" > /opt/WiKID/conf/mode.conf
#sudo yum -y install --nogpg /home/centos/rpms/wikid-*
#mv /root/rpms/security /etc/security
