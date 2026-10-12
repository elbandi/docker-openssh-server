# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/baseimage-ubuntu:jammy@sha256:946d0cc5fc4ccd6d693d8356abf4b1ffbe51572b3914c708ae641d61340ddcab

# renovate: datasource=repology depName=ubuntu_22_04/openssh versioning=loose
ARG OPENSSH_VERSION="1:8.9p1-3ubuntu0.17"

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="elbandi"

# environment settings
ENV DEBIAN_FRONTEND="noninteractive"

RUN \
  echo "**** install runtime packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    at \
    unzip \
    zip \
    logrotate \
    nano \
    netcat-openbsd \
    sudo && \
  echo "**** install openssh-server ****" && \
  apt-get install -y \
    openssh-client=${OPENSSH_VERSION} \
    openssh-server=${OPENSSH_VERSION} \
    openssh-sftp-server=${OPENSSH_VERSION} && \
  printf "Linuxserver.io version: ${VERSION}\nBuild-date: ${BUILD_DATE}" > /build_version && \
  echo "**** patch executable's name ****" && \
  ln -s /usr/sbin/sshd /usr/sbin/sshd.pam && \
  echo "**** setup openssh environment ****" && \
  sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config && \
  sed -i 's/UsePAM yes/UsePAM no/g' /etc/ssh/sshd_config && \
  usermod --shell /bin/bash abc && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

# add local files
COPY /root /

EXPOSE 2222

VOLUME /config
