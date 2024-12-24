FROM --platform=linux/amd64 docker.io/debian:bookworm

RUN apt update && apt install -y \
build-essential \
git
