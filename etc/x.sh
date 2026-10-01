#!/bin/sh

[ ! -d ape/ ] && ./cosmo.sh 
etc/gk.com etc/ninja.k -- $@ || exit 1
ninja -j6 --verbose
