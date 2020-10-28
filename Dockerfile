FROM archlinux:latest

RUN pacman -Syu --noconfirm
RUN pacman-db-upgrade

RUN pacman -S --noconfirm --needed \
        autoconf \
        binutils \
        clang \
        cmake \
        curl \
        fakeroot \
        findutils \
        gawk \
        gdb \
        gettext \
        git \
        gnu-netcat \
        go \
        grep \
        groff \
        hub \
        iproute2 \
        ipython \
        jdk-openjdk \
        libtool \
        ltrace \
        make \
        man-db \
        man-pages \
        nasm \
        neovim \
        nmap \
        patch \
        sed \
        strace \
        sudo \
        texinfo \
        tmux \
        unzip \
        wget \
        zsh

RUN useradd -m -G wheel -s /bin/zsh coma
RUN usermod coma -p cc
RUN usermod root -p cc
RUN echo '%wheel ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

USER coma
WORKDIR /home/coma
SHELL ["/bin/bash", "-c"]

COPY install-dotfiles.bash .
RUN bash install-dotfiles.bash

RUN mkdir -p /home/coma/.local/src/yay-git
RUN git clone https://aur.archlinux.org/yay-git.git /home/coma/.local/src/yay-git
WORKDIR /home/coma/.local/src/yay-git
RUN makepkg -si --noconfirm

SHELL ["/bin/zsh", "-c"]

RUN git clone https://github.com/asdf-vm/asdf.git /home/coma/.asdf
WORKDIR /home/coma/.asdf
RUN git checkout `git describe --abbrev=0 --tags`

RUN source $HOME/.asdf/asdf.sh && asdf plugin-add python
RUN source $HOME/.asdf/asdf.sh && asdf install python 2.7.18
RUN source $HOME/.asdf/asdf.sh && asdf install python latest
RUN source $HOME/.asdf/asdf.sh && asdf global python `asdf list python | tail -n 1` 2.7.18

RUN source $HOME/.asdf/asdf.sh && python3 -m pip install -U pip
RUN source $HOME/.asdf/asdf.sh && pip install --user \
    tldr

RUN source $HOME/.asdf/asdf.sh && asdf plugin-add nodejs https://github.com/asdf-vm/asdf-nodejs.git
RUN bash -c '${ASDF_DATA_DIR:=$HOME/.asdf}/plugins/nodejs/bin/import-release-team-keyring'
RUN source $HOME/.asdf/asdf.sh && asdf install nodejs latest
RUN source $HOME/.asdf/asdf.sh && asdf global nodejs `asdf list nodejs | tail -n 1`

RUN source $HOME/.asdf/asdf.sh && npm install --global \
    yarn
RUN source $HOME/.asdf/asdf.sh && yarn global add \
    nodemon

RUN source $HOME/.asdf/asdf.sh && asdf plugin-add rust https://github.com/code-lever/asdf-rust.git
RUN source $HOME/.asdf/asdf.sh && asdf install rust latest
RUN source $HOME/.asdf/asdf.sh && asdf global rust `asdf list nodejs | tail -n 1`

RUN source $HOME/.asdf/asdf.sh && cargo install \
    lsd \
    du-dust \
    bat \
    broot \
    ripgrep

RUN yay -S --noconfirm \
    bat-extras

RUN source $HOME/.asdf/asdf.sh && asdf reshim

USER root
RUN sudo pacman -Scc --noconfirm

ENTRYPOINT ["/bin/zsh"]