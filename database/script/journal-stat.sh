#!/usr/bin/env bash

# input: medline format file (could be obtained by running commands like
#        `efetch -db pubmed -id 100,200 -format medline`)
# output: table of journal count and impact factors

set -ue

current_dir=$(realpath $(dirname $0))
db_file=${current_dir}/../journal-IF-medline.csv

function format_csv() {
    # use `awk` instead of `gawk` in linux system
    Rscript ${current_dir}/journal-stat.R $db_file $(realpath $1)
}

if [ $# -ge 2 ]; then
    format_csv $1
else
    format_csv $1 \
        | gawk -vFPAT='[^,]*|"[^"]*"' \
            'BEGIN{OFS="\t"} \
             NR==1{print $1,$2,$3,$4} \
             NR>1{printf "%9s\t%s\t\"%6.2f\"\t\"%3d\"\n",$1,$2,$3,$4}' \
        | csvlook -t
fi
