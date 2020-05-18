#!/bin/bash

set -ue

sudo dnf -y install emacs
sudo dnf -y install gcc-c++ gcc-fortran
sudo dnf -y install cmake automake libtool
sudo dnf -y install htop make

# magic monty bash colours
# if we cant find the string
if  grep -q "*/.bash-git-prompt/gitprompt.sh" ~/.bashrc ; then
    git clone https://github.com/magicmonty/bash-git-prompt.git ~/.bash-git-prompt --depth=1
    echo "if [ -f "$HOME/.bash-git-prompt/gitprompt.sh" ]; then" >> ~/.bashrc
    echo "    GIT_PROMPT_ONLY_IN_REPO=1" >> ~/.bashrc
    echo "    source $HOME/.bash-git-prompt/gitprompt.sh" >> ~/.bashrc
    echo "fi" >> ~/.bashrc
fi

sudo dnf -y install hdf5-devel openmpi openmpi-devel mpich mpich-devel redhat-rpm-config
# to cover a bug in openmpi in fedora
if [ ! -d "/usr/lib64/openmpi/include" ] ; then
    sudo mkdir /usr/lib64/openmpi/include
fi
sudo dnf -y install eigen3-devel
sudo dnf -y install micro

sudo dnf -y install tlp tlp-rdw
sudo systemctl enable tlp.service
sudo systemctl enable tlp-sleep.service

sudo dnf -y install openfortivpn
sudo dnf -y install bison valgrind valgrind-devel flex

sudo dnf -y install freecad
sudo dnf -y install libtirpc-devel
sudo dnf -y install boost-devel gmp-devel mpfr-devel
sudo dnf -y install xournal gimp evolution
sudo dnf -y install snapd vtk-devel
sudo ln -s /var/lib/snapd/snap /snap
sudo snap install acrordrdc
pip3 install pandas --user
