#!/usr/bin/env bash
set -ue

cd $(dirname $0)/..

if [ ! -r J_Medline.txt ]; then
    # see also: https://www.nlm.nih.gov/bsd/serfile_addedinfo.html
    wget ftp://ftp.ncbi.nih.gov/pubmed/J_Medline.txt
fi

echo -e "JrId\tJournalTitle\tMedAbbr\tISSN (Print)\tISSN (Online)\tIsoAbbr\tNlmId" \
    > J_Medline.tsv
cat J_Medline.txt \
    | grep -v '^---' \
    | sed -e 's/^[^:]*: //' \
    | paste - - - - - - - \
    >> J_Medline.tsv
