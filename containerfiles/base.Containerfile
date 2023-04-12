FROM quay.io/fedora/fedora-coreos:testing-devel

#common utils
RUN set -x; PACKAGES_INSTALL="curl wget htop screen tmux vim jq tftp"; \
    rpm-ostree install $PACKAGES_INSTALL && ostree container commit

RUN set -x; PACKAGES_INSTALL="zsh"; \
    rpm-ostree install $PACKAGES_INSTALL && ostree container commit

#vcs
RUN set -x; PACKAGES_INSTALL="git git-lfs"; \
    rpm-ostree install $PACKAGES_INSTALL && ostree container commit

#net utils
RUN set -x; PACKAGES_INSTALL="net-tools bridge-utils bind-utils iperf iperf3 iputils iproute mtr ethtool ipmitool"; \
    rpm-ostree install $PACKAGES_INSTALL && ostree container commit

RUN set -x; PACKAGES_INSTALL="python3-pip"; \
    rpm-ostree install $PACKAGES_INSTALL && ostree container commit

RUN set -x; PACKAGES_INSTALL="NetworkManager-ovs open-vm-tools qemu-guest-agent cri-o cri-tools"; \
    rpm-ostree install $PACKAGES_INSTALL && ln -s /usr/sbin/ovs-vswitchd.dpdk /usr/sbin/ovs-vswitchd \
     # Symlink nc to netcat due to known issue in rpm-ostree - https://github.com/coreos/rpm-ostree/issues/1614
     && ln -s /usr/bin/netcat /usr/bin/nc \
     && rm -rf /go /var/lib/unbound /tmp/rpms \
     && systemctl preset-all \
     && ostree container commit
