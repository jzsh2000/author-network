#!/usr/bin/env bash
set -ueo pipefail

author=${1:-regev}
cat ${author}/${author}.txt \
    | grep -e '^PMID' -e '^TA' -e '^JT ' -e '^EDAT' \
    | cut -c7- \
    | paste - - - - \
    | gsed -e "1i pmid\tjournal_title_abbr\tjournal_title\tdate" \
    | tee ${author}/${author}.tsv \
    | csvlook -t
