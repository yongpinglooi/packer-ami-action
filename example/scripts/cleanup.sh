#!/bin/bash -eux

echo "Remove unnecessary packages"
yum -y remove gcc cpp kernel-devel kernel-headers perl

echo "Clean all yum cache"
yum clean all

echo "Remove documentation and other non-essential files"
rm -rf /usr/share/doc/*
rm -rf /usr/share/man/*
rm -rf /usr/share/info/*
rm -rf /usr/share/cracklib*
rm -rf /usr/share/i18n
rm -rf /usr/share/licenses/*
rm -rf /usr/share/locale/*
rm -rf /usr/share/zoneinfo/*

echo "Clean up temporary directories"
rm -rf /tmp/*
rm -rf /var/tmp/*

echo "Truncate log files"
find /var/log -type f -exec truncate -s 0 {} \;

echo "Clear machine-id"
truncate -s 0 /etc/machine-id
[ -f /var/lib/dbus/machine-id ] && truncate -s 0 /var/lib/dbus/machine-id || true

echo "Clear shell history"
unset HISTFILE
rm -f /root/.bash_history
export HISTSIZE=0

echo "Remove SSH host keys (will be regenerated on boot)"
rm -f /etc/ssh/ssh_host_*

echo "Clean cloud-init data (if using cloud-init)"
rm -rf /var/lib/cloud/*

echo "Remove random seed to force regeneration"
rm -f /var/lib/systemd/random-seed
