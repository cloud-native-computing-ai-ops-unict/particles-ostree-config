FROM quay.io/fedora/fedora-coreos:stable

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
