FROM archlinux:latest

USER root
SHELL ["/bin/bash", "-c"]

# WARNING: Will not do anything if buildstep is cached
RUN pacman -Syu --noconfirm
RUN pacman-db-upgrade

RUN pacman -S --noconfirm --needed reflector
RUN reflector --latest 15 --sort rate --protocol https --save /etc/pacman.d/mirrorlist

RUN pacman -S --noconfirm --needed \
    autoconf \
    binutils \
    clang \
    cmake \
    curl \
    fakeroot \
    findutils \
    fzf \
    gawk \
    gdb \
    gettext \
    git \
    gnu-netcat \
    go \
    grep \
    groff \
    iproute2 \
    ipython \
    jdk-openjdk \
    jre-openjdk \
    libtool \
    make \
    man-db \
    man-pages \
    neovim \
    python \
    python-pip \
    sed \
    sudo \
    texinfo \
    thefuck \
    tmux \
    wget \
    which \
    zsh

RUN useradd -m -G wheel -s /bin/zsh coma
RUN usermod coma -p cc
RUN usermod root -p cc

RUN echo '%wheel ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

USER coma
WORKDIR /home/coma
SHELL ["/bin/bash", "-c"]

RUN mkdir '/tmp/scripts'
WORKDIR /tmp/scripts
COPY ./scripts/util.bash .

COPY ./scripts/install-dotfiles .
RUN ./install-dotfiles

RUN echo 'export TERM="xterm-256color"' >> "${HOME}/.profile"
# hadolint ignore=SC2016
RUN echo -e '\nsource "${HOME}/.profile"' >> "${HOME}/.config/zsh/.zshrc"

COPY ./scripts/install-asdf .
RUN ./install-asdf

# python
RUN source "${HOME}/.asdf/asdf.sh" && asdf reshim python && python3 -m pip install -U pip
RUN source "${HOME}/.asdf/asdf.sh" && asdf reshim python && pip install --user \
    tldr

# node
RUN source "${HOME}/.asdf/asdf.sh" && asdf reshim nodejs && npm install --global \
    yarn
RUN source "${HOME}/.asdf/asdf.sh" && asdf reshim nodejs && yarn global add \
    nodemon

# rust
RUN source "${HOME}/.asdf/asdf.sh" && asdf reshim rust && cargo install \
    bat \
    broot \
    du-dust \
    lsd \
    ripgrep

# yay
RUN mkdir -p "${HOME}/.local/src/yay-git"
RUN git clone https://aur.archlinux.org/yay-git.git "${HOME}/.local/src/yay-git"
WORKDIR /home/coma/.local/src/yay-git
RUN makepkg -si --noconfirm

RUN yay -S --noconfirm \
    bat-extras \
    fasd

USER root
RUN pacman -Scc --noconfirm

RUN rm -r /tmp/scripts
WORKDIR /home/coma
USER coma

RUN source "${HOME}/.asdf/asdf.sh" && asdf reshim rust && broot --install
RUN nvim -c ':call dein#install()' -c ':q'

ENTRYPOINT ["/bin/zsh"]
