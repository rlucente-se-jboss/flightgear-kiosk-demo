#!/usr/bin/env bash

. $(dirname $0)/demo.conf

[[ $EUID -ne 0 ]] && exit_on_error "Must run as root"

# enable the CodeReady Builder repo for EPEL
subscription-manager repos --enable codeready-builder-for-rhel-9-x86_64-rpms

# enable EPEL repo
dnf install $EPEL_URL
sudo dnf -y upgrade

# install required packages
dnf -y install gnome-session gnome-kiosk gnome-kiosk-script-session snapd

# enable snapd
systemctl enable --now snapd.socket
ln -s /var/lib/snapd/snap /snap

# set graphical environment
systemctl set-default graphical.target

# check the snap version
snap --version

# install flightgear
snap install flightgear

