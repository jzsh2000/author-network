#!/usr/bin/env bash
set -ueo pipefail

if [ $# -eq 0 ]; then
    echo "Usage  : $0 <author>"
    echo "Example: $0 'Regev, Aviv'"
    exit 1
else
    # full author name
    fau=$(echo "$1" \
        | perl -lane 'if(/,/){print} else{print $F[$#F], ", ", join(" ", @F[0..($#F-1)])}')
    author=$(echo "$fau" | grep -o '^[^,]*' | tr 'A-Z' 'a-z')
fi

bash 0.download-article-info.sh "$fau"
bash 1.get-word-frequency.sh $author
python 2.lemmatizer.py $author
Rscript 3.wordcloud.R $author 80
