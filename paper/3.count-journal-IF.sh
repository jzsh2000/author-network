#!/usr/bin/env bash
set -ueo pipefail

author=${1:-regev}
bash $(dirname $0)/../database/script/journal-stat.sh ${author}/${author}.txt
