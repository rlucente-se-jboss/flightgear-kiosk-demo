#!/usr/bin/env bash

. $(dirname $0)/demo.conf

[[ $EUID -ne 0 ]] && exit_on_error "Must run as root"

# enable the CodeReady Builder repo for EPEL
subscription-manager repos --enable codeready-builder-for-rhel-9-x86_64-rpms

# enable EPEL repo
dnf -y install $EPEL_URL
dnf -y upgrade
dnf -y clean all

# install required packages
dnf -y install gnome-session gnome-kiosk gnome-kiosk-script-session snapd

# enable snapd
systemctl enable --now snapd.socket
ln -s /var/lib/snapd/snap /snap

# set graphical environment
systemctl set-default graphical.target

# check the snap version
snap --version

# wait for snapd start to settle down
for i in {1..10}
do
    echo -n '.'
    sleep 1
done
echo

# install flightgear
snap install flightgear

