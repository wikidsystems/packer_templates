#!/bin/bash

if [ -f /etc/selinux/config ]; then
	sudo sed -i "s/enforcing/permissive/" /etc/selinux/config
fi

RHEL7=`grep "release 7" /etc/redhat-release`

if [ -n "${RHEL7}" ]; then
  echo "RHEL7 detected: ${RHEL7}"
else
  sudo service iptables stop
  sudo chkconfig iptables off
fi
history -c
sudo rm -rf /root/.ssh/authorized_keys

unset HISTFILE
if [ -f /root/.bash_history ]; then
  rm /root/.bash_history
fi
if [ -f /home/centos/.bash_history ]; then
  rm /home/centos/.bash_history
fi

if [ -f /root/.bash_history ]; then
  rm /root/.bash_history
fi


