#!/usr/bin/env bash
set -ue

maindir=`dirname $0`
python $maindir/network.py "$@"
Rscript $maindir/networkD3.R
