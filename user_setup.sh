#!/bin/bash
# run this as a user to setup my config

run() {
    echo 'Setting up AUR'
    setup_AUR

    #echo 'Updating the pacman mirrors'
    #update_repos

    echo 'Getting the dotfiles'
    setup_dotfiles

    echo 'Setting up vim'
    setup_vim
}
setup_AUR() {
        cd "$HOME"
	if [[ ! -d AUR ]]; then
	    mkdir AUR
	fi
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

setup_vim() {
    echo 'Installing vim-plug'
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    vim -c ":PlugInstall" -c ":qall"
}

# to exit immiediately if something goes wrong
set -e

run
