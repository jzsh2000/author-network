#!/usr/bin/env bash
set -ueo pipefail

# example output:
# |------------+--------------------------+--------------+-------+-------------|
# |  NlmId     | MedAbbr                  | ImpactFactor | Count | Count.core  |
# |------------+--------------------------+--------------+-------+-------------|
# |  9604648   | Nat Biotechnol           | 41.667       | 12    | *****       |
# |  0410462   | Nature                   | 40.137       | 16    | ******      |
# |  101124169 | Nat Rev Immunol          | 39.932       | 1     |             |
# |  0404511   | Science                  | 37.205       | 18    | *****       |
# |  0413066   | Cell                     | 30.41        | 25    | *******     |
# |------------+--------------------------+--------------+-------+-------------|

# Count: number of papers
# Count.core: number of papers where the author is the first author or
#             corresponding author

author=${1:-regev}

tmpfile1=$(mktemp)
tmpfile2=$(mktemp)
bash $(dirname $0)/../database/script/journal-stat.sh ${author}/${author}.txt \
    - > $tmpfile1

echo -e 'journal_id\tcount' > $tmpfile2
cat ${author}/${author}.tsv \
    | awk -F'\t' 'NR>1 && $8!="other"{print $5}' \
    | sort \
    | uniq -c \
    | awk 'BEGIN{OFS="\t"} \
           {
               printf "%s\t",$2;
               for(i=0;i<$1;++i) {printf "*", $1}
               printf "\n";
           }' >> $tmpfile2

# cat $tmpfile1
# echo '-----'
# cat $tmpfile2
Rscript $(dirname $0)/merge-file.R $tmpfile1 $tmpfile2 \
    | csvlook
rm $tmpfile1 $tmpfile2
