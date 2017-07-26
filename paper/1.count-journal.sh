#!/usr/bin/env bash
set -ueo pipefail

# extract information from medline format files
#
# use `1.count-journal.R` if you need more detailed data
# e.g. publication type & author type

author=${1:-regev}
cat ${author}/${author}.txt \
    | grep -e '^PMID' -e '^TA' -e '^JT ' -e '^EDAT' \
    | cut -c7- \
    | paste - - - - \
    | gsed -e "1i pmid\tjournal_title_abbr\tjournal_title\tdate" \
    | tee ${author}/${author}_.tsv \
    | csvlook -t
