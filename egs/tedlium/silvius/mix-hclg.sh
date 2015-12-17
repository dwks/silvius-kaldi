#!/bin/bash

. cmd.sh
. path.sh

if [ -z "$1" ]; then
	echo "Usage: $0 graphname"
	exit 1
fi
graph=$1

utils/mkgraph.sh data/lang_fake_G exp/tri_fake exp/tri_fake/$graph || exit 1

