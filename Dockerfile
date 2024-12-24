FROM --platform=linux/amd64 docker.io/debian:bookworm

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
cpio
