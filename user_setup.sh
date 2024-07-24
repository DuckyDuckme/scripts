#!/bin/bash
#
# run this as a user to setup my config

run() {
    echo 'Setting up AUR'
    setup_AUR

    #echo 'Updating the pacman mirrors'
    #update_repos

    echo 'Getting the dotfiles'
    setup_dotfiles

    # echo 'Setting up vim and neovim'
    # setup_nvim
}
setup_AUR() {
    mkdir $HOME/AUR
}

update_repos() {
    cd "$HOME/AUR"
    git clone https://aur.archlinux.org/rate-mirrors.git
    cd rate-mirrors
    makepkg -sicr --noconfirm
    cp /etc/pacman.d/mirrorlist ./mirrorlist.backup

    rate-mirrors arch | doas tee /etc/pacman.d/mirrorlist
}

setup_dotfiles() {
    cd "$HOME"
    if [[ ! -d .dotfiles ]]; then
	git clone https://github.com/DuckyDuckme/.dotfiles.git
	cd .dotfiles
	chmod +x bootstrap.sh
	./bootstrap.sh
    else
	echo "Folder ``.dotfiles'' already exists."
    fi
}

setup_nvim() {
    # At this point neovim should be installed and configured
    if [[ -d ~/.config/nvim ]]; then
	ln -s ~/.vimrc ~/.config/nvim/init.vim
    fi

    # Install all the plugins
    nvim -es -u init.vim -i NONE -c "PlugInstall" -c "qa"
}

run
