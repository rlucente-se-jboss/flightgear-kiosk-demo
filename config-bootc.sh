#!/usr/bin/env bash

. $(dirname $0)/demo.conf

[[ $EUID -ne 0 ]] && exit_on_error "Must run as root"

# some packages in EPEL require packages in the codeready-builder repo
subscription-manager repos \
    --enable codeready-builder-for-rhel-9-x86_64-rpms

# enable the EPEL repo and install needed tools
dnf -y install $EPEL_URL container-tools lorax git

