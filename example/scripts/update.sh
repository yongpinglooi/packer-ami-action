#!/bin/bash -eux

# Update all packages to the latest version
yum clean all
yum -y update

# Optionally install common tools (customize if needed)
yum -y install wget curl unzip vim

# Disable auto updates if not desired
systemctl stop yum-cron || true
systemctl disable yum-cron || true

# Clean up cache to reduce AMI size
yum clean all

# Print OS version for logging
cat /etc/os-release
