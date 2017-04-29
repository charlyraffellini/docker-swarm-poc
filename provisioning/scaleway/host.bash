#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

apt-get update -q
apt-get install  -y -q git
apt-get install  -y -q vagrant

bash ./virtualbaox_install.bash

