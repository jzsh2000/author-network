# dependancies

* entrez-direct <https://www.ncbi.nlm.nih.gov/news/02-06-2014-entrez-direct-released/>
* `NLTK` module (in python)
* `tidyverse` and `wordcloud` package (in R)

# usage

Run the following command for test:
```bash
./run.sh 'Regev, Aviv'
```

Then a word-cloud image called 'regev.pdf' should appear in the directory
'regev'. If some error occurs, please make sure that all dependencies are
installed. Here the 'Regev, Aviv' can be replaced by any other author name,
notice that the family name and the given name are sperated by a comma.

> Warning: If the author name be used to run the script is too common, the
> program may take a long time and not output desired results, especially when
> the name is in the format of Chinese pinyin.
