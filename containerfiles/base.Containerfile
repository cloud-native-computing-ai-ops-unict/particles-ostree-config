FROM quay.io/fedora/fedora-coreos:stable

RUN cat /etc/os-release \
    && rpm-ostree --version \
    && ostree --version

#common utils
RUN set -x; PACKAGES_INSTALL="curl wget htop screen tmux vim jq tftp python3-pip util-linux-user"; \
    rpm-ostree install $PACKAGES_INSTALL && ostree container commit

RUN set -x; PACKAGES_INSTALL="zsh"; \
    rpm-ostree install $PACKAGES_INSTALL && ostree container commit

#vcs
RUN set -x; PACKAGES_INSTALL="git git-lfs"; \
    rpm-ostree install $PACKAGES_INSTALL && ostree container commit

#net utils
RUN set -x; PACKAGES_INSTALL="net-tools bridge-utils bind-utils iperf iperf3 iputils iproute mtr ethtool ipmitool"; \
    rpm-ostree install $PACKAGES_INSTALL && ostree container commit

COPY root/ /

# disable zincati updates
RUN set -x; sed -i \
      's/AutomaticUpdatePolicy=.*/AutomaticUpdatePolicy=stage/' \
      /etc/rpm-ostreed.conf \
 && systemctl preset-all \
 && ostree container commit

 # zsh setup
 RUN HOME=/tmp ZSH=/usr/lib/ohmyzsh \
     sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
     && set -x \
     && wget -qO /usr/lib/ohmyzsh/custom/kube-ps1.plugin.zsh \
         https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/kube-ps1/kube-ps1.plugin.zsh \
     && mv /usr/share/zsh/*.zsh /usr/lib/ohmyzsh/custom/ \
     && git clone https://github.com/zsh-users/zsh-history-substring-search \
      /usr/lib/ohmyzsh/custom/plugins/zsh-history-subscring-search \
     && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
      /usr/lib/ohmyzsh/custom/plugins/zsh-syntax-highlighting \
     && chsh -s /bin/zsh root \
     && echo 'PATH=~/bin:~/.bin:~/.opt/bin:$PATH' >> /etc/zshenv \
     && sed -i 's|^SHELL=.*|SHELL=/usr/bin/zsh|' /etc/default/useradd \
     # ${VARIANT_ID^} is not posix compliant and is not parsed correctly by zsh \
     && sed -i 's/VARIANT_ID^/VARIANT_ID/' /etc/profile.d/toolbox.sh \
     && ostree container commit