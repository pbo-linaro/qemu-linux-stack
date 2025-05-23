FROM --platform=linux/amd64 docker.io/debian:trixie

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
proot \
qemu-user \
gdb-multiarch \
cgdb
RUN apt update && apt install -y podman
