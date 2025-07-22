FROM --platform=linux/amd64 docker.io/amd64/debian:trixie

RUN apt update && apt install -y \
    bash-completion pciutils net-tools \
    iputils-ping util-linux procps htop
RUN apt update && apt install -y strace
RUN apt update && apt install -y kmod
RUN echo host > /hostname
RUN mkdir /host
COPY --from=common resolv.conf /etc/resolv.conf
COPY --from=common init /init
