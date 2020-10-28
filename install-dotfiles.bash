# /bin/bash
# credits: https://www.atlassian.com/git/tutorials/dotfiles

DOTFILES_DIRECTORY="${HOME}/.local/share/dotfiles"
BACKUP_DIRECTORY="${HOME}/.config-backup"

# zinit - zsh plugin manager
sh -c "$(curl -fsSL https://raw.githubusercontent.com/zdharma/zinit/master/doc/install.sh)"
# dein - vim plugin manager
curl https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh | sh -s '/home/coma/.local/share/dein'
# tpm - tmux plugin manager
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# My dotfiles
git clone --bare 'https://github.com/coma64/dotfiles' "${DOTFILES_DIRECTORY}"

# Interact with dotfiles bare repo
config() {
    git --git-dir="${DOTFILES_DIRECTORY}" --work-tree="${HOME}" "${@}"
}

# Backup file to backup directory
backup_file() {
    mkdir --parents $(dirname "${BACKUP_DIRECTORY}/${1}")
    mv "${1}" "${BACKUP_DIRECTORY}/${1}"
}

if config checkout $1; then
    echo 'Checked out config.';
else
    echo 'Backing up pre-existing dotfiles to ~/.config-backup';

    mkdir -p "${BACKUP_DIRECTORY}"
    export -f backup_file
    config checkout $1 2>&1 | egrep '\s+\.' | awk {'print $1'} | xargs -I{} bash -c 'backup_file {} && echo "Backing up {}"'
fi

config checkout $1 || echo 'Failed installing dotfiles. Exiting' && exit 1
config config status.showUntrackedFiles no
