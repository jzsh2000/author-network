#!/usr/bin/env bash

# input: medline format file (could be obtained by running commands like
#        `efetch -db pubmed -id 100,200 -format medline`)
# output: table of journal count and impact factors

set -ue

current_dir=$(realpath $(dirname $0))
db_file=${current_dir}/../journal-IF-medline.csv

# use `awk` instead of `gawk` in linux system
Rscript ${current_dir}/journal-stat.R $db_file $(realpath $1) \
    | gawk -vFPAT='[^,]*|"[^"]*"' 'NR==1{print}NR>1{printf "%s,\"%6.2f\",\"%3d\"\n",$1,$2,$3}'\
    | csvlook
