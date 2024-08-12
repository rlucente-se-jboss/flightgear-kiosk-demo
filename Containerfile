FROM registry.redhat.io/rhel9/rhel-bootc:latest

# configure an insecure local registry
RUN  mkdir -p /etc/containers/registries.conf.d
COPY 999-local-registry.conf /etc/containers/registries.conf.d/

# install and configure a graphical environment with FlightGear
RUN --mount=type=bind,relabel=shared,source=fg-rpms.tgz,target=/tmp/fg-rpms.tgz \
       tar zxf /tmp/fg-rpms.tgz \
    && cd flightgear-rpms \
    && dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm \
    && dnf -y install --enablerepo=codeready-builder-for-rhel-9-x86_64-rpms *.rpm \
           gnome-shell gnome-terminal \
    && cd / \
    && rm -fr flightgear-rpms \
    && systemctl set-default graphical.target
