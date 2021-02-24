#!/usr/bin/env bash
set -euo pipefail

apt-get -q update
DEBIAN_FRONTEND=noninteractive apt-get -qq -y -o Dpkg::Options::="--force-confnew" dist-upgrade
apt-get -q -y --purge autoremove
apt-get autoclean

apt-get -q -y install software-properties-common
