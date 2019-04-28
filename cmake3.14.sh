version=3.14
build=3
mkdir ~/temp
cd ~/temp
wget https://cmake.org/files/v$version/cmake-$version.$build-Linux-x86_64.sh 
mkdir /opt/cmake
sh cmake-$version.$build-Linux-x86_64.sh --prefix=/opt/cmake
ln -s /opt/cmake/bin/cmake /usr/bin/cmake
