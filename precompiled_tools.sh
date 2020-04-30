#!/bin/bash

set -ue

export WORKDIR=/home/adavis/opt/

function build_visit() {
    if [ -d "$WORKDIR/visit" ] ; then
       return
    fi
    wget https://github.com/visit-dav/visit/releases/download/v3.1.1/visit3_1_1.linux-x86_64-fedora27.tar.gz
    tar -zxf visit3_1_1.linux-x86_64-fedora27.tar.gz
    mv visit3_1_1.linux-x86_64 visit
    if ! grep -q "*/visit" ~/.bashrc ; then
        echo 'export PATH=$PATH:$PWD/visit/bin' >> ~/.bashrc
    fi
    rm -rf visit3_1_1.linux-x86_64-fedora27.tar.gz
}

function build_paraview() {
    if [ -d "$WORKDIR/paraview" ] ; then
       return
    fi
    wget "https://www.paraview.org/paraview-downloads/download.php?submit=Download&version=v5.8&type=binary&os=Linux&downloadFile=ParaView-5.8.0-MPI-Linux-Python3.7-64bit.tar.gz" -O ParaView-5.8.0-MPI-Linux-Python3.7-64bit.tar.gz
    tar -zxf ParaView-5.8.0-MPI-Linux-Python3.7-64bit.tar.gz
    mv ParaView-5.8.0-MPI-Linux-Python3.7-64bit paraview
    if ! grep -q "*/paraview" ~/.bashrc ; then
        echo "export PATH='$PATH':$PWD/paraview/bin" >> ~/.bashrc
    fi
    rm -rf ParaView-5.8.0-MPI-Linux-Python3.7-64bit.tar.gz
}

cd $WORKDIR

build_visit
build_paraview