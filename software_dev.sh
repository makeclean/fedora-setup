#!/bin/bash

set -ue

export WORKDIR=/home/adavis/opt/

function build_moab() {
    cd $WORKDIR
    if [ -d "$WORKDIR/moab" ] ; then
       return
    fi
    git clone https://bitbucket.org/fathomteam/moab
    cd moab
    git checkout master
    mkdir bld
    cd bld
    cmake .. -DENABLE_BLASLAPACK=OFF -DENABLE_HDF5=ON -DCMAKE_INSTALL_PREFIX=..
    make -j4
    make install
    cd ..
     if ! grep -q "*/moab" ~/.bashrc ; then
        echo "export PATH=$PATH:$PWD/moab/bin" >> ~/.bashrc
        echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PWD/moab/lib" >> ~/.bashrc
    fi
}

function build_dagmc() {
    cd $WORKDIR
    if [ -d "$WORKDIR/dagmc" ] ; then
       return
    fi
    git clone https://github.com/svalinn/dagmc
    cd dagmc
    mkdir bld
    cd bld
    cmake .. -DMOAB_DIR=$WORKDIR/moab -DBUILD_STATIC_LIBS=OFF -DCMAKE_INSTALL_PREFIX=..
    make -j4
    make install
    cd ..
    if ! grep -q "*/dagmc" ~/.bashrc ; then
        echo "export PATH=$PATH:$PWD/dagmc/bin" >> ~/.bashrc
        echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PWD/dagmc/lib" >> ~/.bashrc
    fi
}

function build_openmc() {
    module purge
    module load mpi/mpich-x86_64
    cd $WORKDIR
    if [ -d "$WORKDIR/openmc" ] ; then
       return
    fi
    git clone https://github.com/openmc-dev/openmc
    cd openmc
    git checkout develop
    mkdir bld
    cd bld
    CXX=mpic++ CC=mpicc cmake .. -DCMAKE_INSTALL_PREFIX=..
    make -j4
    make install
    cd ..
}

function _build_petsc_313() {
    module purge
    module load mpi/mpich-x86_64
    cd $WORKDIR
    if [ -d "$WORKDIR/petsc" ] ; then
       return
    fi
    mkdir petsc
    cd petsc
    curl -L -O http://ftp.mcs.anl.gov/pub/petsc/release-snapshots/petsc-3.13.2.tar.gz
    tar -xf petsc-3.13.2.tar.gz -C .
    cd petsc-3.13.2
    sed -i '55s#.*#      args.append(\x27-DTPL_PARMETIS_INCLUDE_DIRS=\"/home/adavis/opt/petsc/include/\"  \x27)#' /home/adavis/opt/petsc/petsc-3.13.2/config/BuildSystem/config/packages/SuperLU_DIST.py
    ./configure \
	--prefix=$WORKDIR/petsc \
	--with-debugging=0 \
	--with-ssl=0 \
	--with-pic=1 \
	--with-openmp=1 \
	--with-mpi=1 \
	--with-shared-libraries=1 \
	--with-cxx-dialect=C++11 \
        --with-64-bit-indices \
    --with-fortran-bindings=0 \
    --with-sowing=0 \
    --download-hypre=1 \
    --download-fblaslapack=1 \
    --download-metis=1 \
    --download-ptscotch=1 \
    --download-parmetis=1 \
    --download-superlu_dist=1 \
    --download-scalapack=1 \
    --download-mumps=1 \
    --download-slepc=1 \
    --with-mpi-dir=/usr/lib64/mpich/ \
    PETSC_DIR=`pwd` PETSC_ARCH=linux-opt
    # l55 of superlu_dist.py needs to be replaced with 
    #     args.append('-DTPL_PARMETIS_INCLUDE_DIRS="/home/adavis/opt/petsc/petsc/include/"')
    make PETSC_DIR=$WORKDIR/petsc/petsc-3.13.2 PETSC_ARCH=linux-opt all
    make PETSC_DIR=$WORKDIR/petsc/petsc-3.13.2 PETSC_ARCH=linux-opt install
    make PETSC_DIR=/home/adavis/opt/petsc PETSC_ARCH="" check
    cd ..
    cd ..
    export PETSC_DIR=$WORKDIR/petsc
}   

function _build_petsc() {
    module purge
    module load mpi/mpich-x86_64
    cd $WORKDIR
    if [ -d "$WORKDIR/petsc" ] ; then
       return
    fi
    mkdir petsc
    cd petsc
    curl -L -O http://ftp.mcs.anl.gov/pub/petsc/release-snapshots/petsc-3.11.4.tar.gz
    tar -xf petsc-3.11.4.tar.gz -C .
    cd petsc-3.11.4
    ./configure \
	--prefix=$WORKDIR/petsc \
	--with-debugging=0 \
	--with-ssl=0 \
	--with-pic=1 \
	--with-openmp=1 \
	--with-mpi=1 \
	--with-shared-libraries=1 \
        --with-64-bit-indices \
    --with-cxx-dialect=C++11 \
    --with-fortran-bindings=0 \
    --with-sowing=0 \
    --download-hypre=1 \
    --download-fblaslapack=1 \
    --download-metis=1 \
    --download-ptscotch=1 \
    --download-parmetis=1 \
    --download-superlu_dist=1 \
    --download-scalapack=1 \
    --download-mumps=1 \
    --download-slepc=1 \
#    --with-mpi-dir=/usr/lib64/mpich/ \
    PETSC_DIR=`pwd` PETSC_ARCH=linux-opt    
    make PETSC_DIR=$WORKDIR/petsc/petsc-3.11.4 PETSC_ARCH=linux-opt all
    make PETSC_DIR=$WORKDIR/petsc/petsc-3.11.4 PETSC_ARCH=linux-opt install
    make PETSC_DIR=$WORKDIR/petsc PETSC_ARCH="" test
    cd ..
    cd ..
    export PETSC_DIR=$WORKDIR/petsc
}   

function build_moose() {
    module purge
    module load mpi/mpich-x86_64
    export MOOSE_JOBS=32
    cd $WORKDIR
    if [ -d "$WORKDIR/moose" ] ; then
       return
    fi
    _build_petsc_313
    git clone https://github.com/idaholab/moose
    cd moose
    git checkout master
    export PETSC_DIR=$WORKDIR/petsc
    export CC=mpicc
    export CXX=mpicxx
    export F90=mpif90
    export F77=mpif77
    export FC=mpif90
    ./scripts/update_and_rebuild_libmesh.sh --with-mpi
    cd framework
    ./configure --with-derivative-size=180
    make -j4
    cd ..
    cd modules
#    ./configure --with-derivative-size=180
    make -j4
    cd ..
    cd test
    make -j 4
    ./run_tests -j 4
    cd ..
    cd modules
    make -j 4
    cd ..
    cd ..
}

function _build_hypre() {
    module purge
    module load mpi/mpich-x86_64
    cd $WORKDIR
    if [ -d "$WORKDIR/hypre" ] ; then
       return
    fi
    git clone https://github.com/hypre-space/hypre
    cd hypre
    mkdir bld
    cd bld
    cmake ../src/ -DCMAKE_INSTALL_PREFIX=.. -DHYPRE_WITH_OPENMP=ON
    make -j4
    make install
    cd ..
    cd ..
}

function _build_metis() {
    module purge
    module load mpi/mpich-x86_64
    cd $WORKDIR
    if [ -d "$WORKDIR/metis" ] ; then
       return
    fi
    git clone --recursive https://github.com/KarypisLab/METIS.git metis
    cd metis
    make config shared=1 cc=gcc prefix=~/opt/metis
    make install
    cd ..
}

function build_mfem() {
    module purge
    module load mpi/mpich-x86_64
    cd $WORKDIR
    if [ -d "$WORKDIR/mfem" ] ; then
       return
    fi
    _build_hypre
    _build_metis
    git clone https://github.com/mfem/mfem
    cd mfem
    git checkout master
    export CC=mpicc
    export CXX=mpicxx
    export F90=mpif90
    export F77=mpif77
    export FC=mpif90
    mkdir bld
    cd bld
    cmake .. -DHYPRE_DIR=$WORKDIR/hypre -DMETIS_DIR=$WORKDIR/metis -DMFEM_ENABLE_EXAMPLES=ON -DMFEM_ENABLE_MINIAPPS=ON \
    -DMFEM_THREAD_SAFE=ON -DMFEM_USE_MPI=ON -DMFEM_USE_OPENMP=ON \
    -DCMAKE_INSTALL_PREFIX=..
    make -j4
    make install
    cd ..
    cd ..
}

build_tetwild() {
    cd $WORKDIR
    if [ -d "$WORKDIR/tetwild" ] ; then
       return
    fi
    git clone https://github.com/Yixin-Hu/TetWild tetwild
    cd tetwild
    mkdir bld
    cd bld
    cmake .. -DBoost_ATOMIC_LIBRARY_RELEASE=/usr/lib64/libboost_atomic.so \
    -DBoost_SYSTEM_LIBRARY_RELEASE=/usr/lib64/libboost_system.so \
    -DBoost_THREAD_LIBRARY_RELEASE=/usr/lib64/libboost_thread.so \
    -DBoost_CHRONO_LIBRARY_RELEASE=/usr/lib64/libboost_chrono.so \
    -DBoost_DATE_TIME_LIBRARY_RELEASE=/usr/lib64/libboost_date_time.so \
    -DCMAKE_INSTALL_PREFIX=..
    make -j4
    make install
    cd ..
    cd ..
}

build_geant4() {
    cd $WORKDIR
    if [ -d "$WORKDIR/geant4" ] ; then
       return
    fi
    git clone https://github.com/Geant4/geant4
    cd geant4
    mkdir bld
    cd bld
    cmake .. -DCMAKE_INSTALL_PREFIX=$WORKDIR/geant4 \
	  -DGEANT4_BUILD_MULTITHREADED=ON \
	  -DGEANT4_INSTALL_DATA=ON \
	  -DGEANT4_USE_GDML=ON \
	  -DGEANT4_USE_OPENGL=ON \
	  -DGEANT4_USE_QT=ON \
	  -DGEANT4_USE_RAYTRACER_X11=ON    
    make -j4
    make install
    cd ..
    cd ..
}

if [ ! -d "$WORKDIR" ] ; then
    mkdir $WORKDIR
fi

build_moab
build_dagmc
build_openmc
build_moose
build_mfem
build_tetwild
build_geant4
