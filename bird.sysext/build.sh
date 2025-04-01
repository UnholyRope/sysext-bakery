#!/bin/ash
#
# Build script helper for bird sysext.
# This script runs inside an ephemeral alpine container.
# It builds a static bird and exports the binary to a bind-mounted volume.
# See https://github.com/CZ-NIC/bird/blob/master/INSTALL for install instructions.
# 
set -euo pipefail

version="$1"
export_user_group="$2"

apk --no-cache add \
  git \
  autoconf \
  make \
  build-base \
  bison \
  m4 \
  flex \
  ncurses-dev \
  readline-dev \
  libssh-dev \
  linux-headers

cd /opt
git clone https://github.com/CZ-NIC/bird.git --depth 1 --branch v${version} --single-branch
cd /opt/bird

autoreconf
./configure \
  --prefix=/usr \
  --exec_prefix=/usr \
  --sbindir=/usr/bin \
  --sysconfdir=/etc/bird \
  --localstatedir=/var \
  --runstatedir=/run 
make
make DESTDIR=/install_root install

rm -rf /install_root/usr/etc
chown -R "$export_user_group" /install_root
