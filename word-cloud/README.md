About
=====
This module is used to generate a word-cloud image for the abstracts of
publications of an author.

Dependancies
============

* entrez-direct <https://www.ncbi.nlm.nih.gov/books/NBK179288/>
* `NLTK` module (in python)
* `tidyverse` and `wordcloud` package (in R)

Usage
=====

Run the following command for test:
```bash
bash run.sh 'Aviv Regev'
```

Then a word-cloud image called `pubmed.word.pdf` should appear in the directory
`regev`. If some error occurs, please make sure that all dependencies are
installed. Here the 'Aviv Regev' can be replaced by any other author names.

> Note: Here 'Aviv Regev' has the same effect as 'Regev, Aviv'. Regev is the
> family name, and Aviv is the given name.

> Warning: If the author name be used to run the script is too common, the
> program may take a long time and not output desired results, especially when
> the name is in the format of Chinese pinyin.

Example
=======

![word cloud (Regev)](example/regev.png?raw=true "Word Cloud Image - Aviv Regev")
