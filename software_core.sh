#!/bin/bash

set -ue

sudo dnf -y install emacs
sudo dnf -y install gcc-c++ gcc-fortran
sudo dnf -y install cmake automake libtool
sudo dnf -y install htop

# magic monty bash colours
# if we cant find the string
if  grep -q "*/.bash-git-prompt/gitprompt.sh" ~/.bashrc ; then
    git clone https://github.com/magicmonty/bash-git-prompt.git ~/.bash-git-prompt --depth=1
    echo "if [ -f "$HOME/.bash-git-prompt/gitprompt.sh" ]; then" >> ~/.bashrc
    echo "    GIT_PROMPT_ONLY_IN_REPO=1" >> ~/.bashrc
    echo "    source $HOME/.bash-git-prompt/gitprompt.sh" >> ~/.bashrc
    echo "fi" >> ~/.bashrc
fi

sudo dnf -y install hdf5-devel openmpi
