#!/usr/bin/env bash
set -ueo pipefail

if [ $# -eq 0 ]; then
    echo "Usage  : $0 <author>"
    echo "Example: $0 'Aviv Regev'"
    exit 1
else
    # Full author name, 'Aviv Regev' will be formatted to 'Regev, Aviv'
    fau=$(echo "$1" \
        | perl -lane 'if(/,/){print} else{print $F[$#F], ", ", join(" ", @F[0..($#F-1)])}')

    if [ $# -ge 2 ]; then
        # An optional parameter is the name of output directory
        author="$2"
    else
        author=$(echo "$fau" | grep -o '^[^,]*' | tr 'A-Z' 'a-z')
    fi
fi

bash 0.download-article-info.sh "$fau" "$author"
bash 1.get-word-frequency.sh "$author"
python 2.lemmatizer.py "$author"
Rscript 3.wordcloud.R "$author" 80
