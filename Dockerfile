FROM docker.io/debian:trixie

RUN apt update && apt install -y \
build-essential \
git \
gcc-aarch64-linux-gnu \
g++-aarch64-linux-gnu \
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
RUN mkdir /opt/compiler_wrappers && \
    for c in gcc g++ aarch64-linux-gnu-gcc aarch64-linux-gnu-g++; do \
        echo "#!/usr/bin/env bash" > /opt/compiler_wrappers/$c &&\
        echo "ccache /usr/bin/$c \"\$@\" "\
             "-fno-omit-frame-pointer -mno-omit-leaf-frame-pointer"\
             >> /opt/compiler_wrappers/$c &&\
        chmod +x /opt/compiler_wrappers/$c;\
    done
ENV PATH=/opt/compiler_wrappers:$PATH
ENV LANG=en_US.UTF-8
