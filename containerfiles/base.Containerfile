FROM quay.io/fedora/fedora-coreos:stable

RUN cat /etc/os-release \
    && rpm-ostree --version \
    && ostree --version

#disable selinux

RUN set -x; PACKAGES_INSTALL="grubby"; \
    rpm-ostree install $PACKAGES_INSTALL && \
    grubby --update-kernel ALL --args selinux=0 && \
    ostree container commit

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

COPY . .

RUN cp -irvf overlay.d/*/* / \
    && rpm-ostree install NetworkManager-ovs \
    && rpm-ostree cleanup -m \
    # Symlink ovs-vswitchd to dpdk version of OVS
    && ln -s /usr/sbin/ovs-vswitchd.dpdk /usr/sbin/ovs-vswitchd \
    && rm -rf /go /tmp/rpms /var/cache /var/lib/unbound \
    && systemctl preset-all \
    && ostree container commit