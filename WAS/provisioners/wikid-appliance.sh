history -c



sudo mv -f /home/centos/rpms/motd /etc/
mkdir /root/.ssh
cp /root/rpms/authorized_keys /root/.ssh/authorized_keys
sudo rm /root/.ssh/authorized_keys
sudo rm /root/.bash_history
sudo rm -Rf /home/ec2-user/.ssh/authorized_keys
rm -Rf /home/centos/.ssh/authorized_keys
#rmdir /home/ec2-user/.ssh
# setup ec2 user

#sudo useradd -m -s /bin/bash ec2-user
#mkdir /home/ec2-user/.ssh
#sudo chown -R ec2-user:ec2-user /home/ec2-user/.ssh/
sudo \cp -rf /home/centos/rpms/rc.local /etc/
#\cp -rf /root/rpms/S50getsshkey /etc/rc2.d/
#sudo chmod -R 0700 /home/ec2-user/.ssh
sudo mkdir /home/centos/tmp
sudo \cp -rf /home/centos/rpms/ifcfg-eth /etc/sysconfig/network-scripts/

sudo yum -y update
sudo yum install -y java-1.8.0-openjdk ntp mlocate vim policycoreutils
