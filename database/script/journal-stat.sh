#!/usr/bin/env bash

# input: medline format file (could be obtained by running commands like
#        `efetch -db pubmed -id 100,200 -format medline`)
# output: table of journal count and impact factors

set -ue

current_dir=$(realpath $(dirname $0))
db_file=${current_dir}/../journal-IF-medline.csv
Rscript ${current_dir}/journal-stat.R $db_file $(realpath $1) \
    | csvlook
