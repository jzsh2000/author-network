#!/usr/bin/env bash
set -ueo pipefail

# Full author name
fau=${1:-Regev, Aviv}
# author=$(echo $fau | grep -o '^[^,]*' | tr 'A-Z' 'a-z')
author=${2:-regev}
query_string="\"${fau}\"[FAU]"
echo "query string: $query_string"

mkdir -p $author
esearch -db pubmed -query "$query_string" \
    | efetch -format medline \
    > ${author}/pubmed.txt
