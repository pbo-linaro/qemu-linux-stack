FROM --platform=linux/arm64 docker.io/arm64v8/debian:trixie

RUN apt update && apt install -y \
    bash-completion pciutils net-tools \
    iputils-ping util-linux procps htop
RUN apt update && apt install -y \
    --no-install-recommends \
    qemu-system-aarch64 ipxe-qemu
RUN apt update && apt install -y strace
RUN echo host > /hostname
COPY --from=common resolv.conf /etc/resolv.conf
COPY --from=common init /init
