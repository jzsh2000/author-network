#!/usr/bin/env bash
set -ueo pipefail

author=${1:-regev}
medline_file=${author}/pubmed.txt
abstract_file=${author}/pubmed.abstract.txt
abstract_tok_file=${author}/pubmed.abstract.tok.txt
abstract_true_file=${author}/pubmed.abstract.true.txt
truecase_model=${author}/truecase-model
word_file=${author}/pubmed.word.txt

cat $medline_file \
    | sed -n '/^AB /,/^[^ ]/p' \
    | sed -e 's/^[^A ].*//' \
    | sed -e 's/^AB  -/     /' -e 's/^  *//' \
    > $abstract_file

cat $abstract_file \
    | ./moses-scripts/tokenizer.perl -l en \
    > $abstract_tok_file

./moses-scripts/train-truecaser.perl \
    --model $truecase_model \
    --corpus $abstract_tok_file

./moses-scripts/truecase.perl \
    --model $truecase_model \
    < $abstract_tok_file \
    > $abstract_true_file

cat $abstract_true_file \
    | grep -owP '[-\w]+' \
    | grep -v '^[-0-9]' \
    | grep -v -- '-$' \
    | awk 'length($0) >= 3' \
    | sort \
    | uniq -c \
    | awk 'BEGIN{OFS="\t"}{print $2,$1}' \
    | sort -k1 \
    > $word_file
