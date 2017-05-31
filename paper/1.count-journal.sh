#!/usr/bin/env bash
set -ueo pipefail

author=${1:-regev}
cat ${author}/${author}.txt \
    | grep -e '^TA' -e '^JT ' \
    | cut -c7- \
    | paste - - \
    | sort \
    | uniq -c \
    | sort -k1,1nr \
    | gsed -e '1i Count\tTitle Abbreviation\tTitle' -e 's/^  *//' -e 's/ /\t/' \
    | tee ${author}/${author}.tsv \
    | csvlook -t
