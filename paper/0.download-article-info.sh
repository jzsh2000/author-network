#!/usr/bin/env bash
set -ueo pipefail

# Full author name
fau=${1:-Regev, Aviv}
author=$(echo $fau | grep -o '^[^,]*' | tr 'A-Z' 'a-z')
query_string="\"${fau}\"[FAU]"
echo "query string: $query_string"

mkdir -p $author
esearch -db pubmed -query "$query_string" \
    | efetch -format medline \
    > ${author}/${author}.txt

cat ${author}/${author}.txt \
    | grep '^PMID-' \
    | cut -c7- \
    | parallel --jobs 1 \
        echo {} ';' \
        elink -db pubmed -target pubmed -name pubmed_pubmed_citedin -id {} \
        '|' efetch -format uid \
        '|' wc -l \
    | paste - - \
    > ${author}/${author}.citedin
