#!/usr/bin/env python

import sys
import os.path
from nltk.stem import PorterStemmer, WordNetLemmatizer
wnl = WordNetLemmatizer()

stopword = open('stopword.txt').readlines()
stopword = [word.strip() for word in stopword]

if len(sys.argv) == 1:
    author = 'regev'
else:
    author = sys.argv[1]

word_file = os.path.join(author, author + '.word.txt')
word_dict = {}
for line in open(word_file).readlines():
    word, freq = line.split()
    word = wnl.lemmatize(word)
    if word in stopword:
        continue

    freq = int(freq)
    if word not in word_dict:
        word_dict[word] = freq
    else:
        word_dict[word] += freq


out_file = os.path.join(author, author + '.word.clean.txt')
with open(out_file, 'w') as f:
    f.write('word\tfreq\n')
    for word, freq in word_dict.items():
        f.write("%s\t%d\n" % (word, freq))
