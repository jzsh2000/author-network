# functions

Generate a plot for an author's publications in [pubmed](https://www.ncbi.nlm.nih.gov/pubmed/)

# dependancies

* NCBI [entrez-direct](https://www.ncbi.nlm.nih.gov/news/02-06-2014-entrez-direct-released/)
* [csvkit](https://csvkit.readthedocs.io/)
* R packages:
    - [tidyverse](https://github.com/tidyverse/tidyverse)
    - [plotly](https://github.com/ropensci/plotly)


# usage

Run the following command for test:
```bash
./run.sh 'Regev, Aviv'
```

Then you could see a folder called `regev` (the family name of the specified
author) in the current directory, the output images are `regev.pdf` and
`regev.html` in that folder.
