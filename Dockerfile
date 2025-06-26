FROM docker.io/debian:trixie

RUN apt update && apt install -y \
build-essential \
git \
gcc-aarch64-linux-gnu \
bison \
flex \
bc \
libssl-dev \
python3 \
rsync \
cpio \
wget \
qemu-user \
gdb-multiarch \
cgdb
RUN apt update && apt install -y \
e2fsprogs libarchive13t64 locales-all
RUN apt update && apt install -y \
libgnutls28-dev
RUN apt update && apt install -y ccache
ENV PATH=/usr/lib/ccache:$PATH
ENV LANG=en_US.UTF-8
