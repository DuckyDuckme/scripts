#!/bin/bash
# A small script to configure all my config and dotfiles from git

cd /home/ducky

echo 'Configure git'
git config --global user.name "Krzysztof Jan Pudowski"
git config --global user.email "krzysiek.pudowski@gmail.com"

echo 'Getting my dotfiles'
git clone https://github.com/DuckyDuckme/dotfiles.git

cd ./dotfiles

# I feel like there is a nice for-loop way to do that
mv .bashrc ../
mv ,inputrc ../
mv .vimrc ../
mv .xinitrc ../