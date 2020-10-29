FROM archlinux:20200908

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
        iproute2 \
        ipython \
        libtool \
        make \
        man-db \
        man-pages \
        neovim \
        sed \
        texinfo \
        tmux \
        wget \
        zsh

RUN mkdir -p '/home/coma/.local/bin'
RUN wget -o '/home/coma/.local/bin/gosu' 'https://github.com/tianon/gosu/releases/download/1.12/gosu-amd64'

RUN useradd -m -s /bin/zsh coma
RUN usermod coma -p cc
RUN usermod root -p cc

USER coma
WORKDIR /home/coma
SHELL ["/bin/bash", "-o pipefail", "-c"]

COPY install-dotfiles .
RUN ./install-dotfiles

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
RUN bash -c '${ASDF_DATA_DIR:-$HOME/.asdf}/plugins/nodejs/bin/import-release-team-keyring'
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
RUN pacman -Scc --noconfirm

ENTRYPOINT ["/bin/zsh"]
