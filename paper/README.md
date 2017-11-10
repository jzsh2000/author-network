Function
========

Generate a plot for an author's publications in [pubmed](https://www.ncbi.nlm.nih.gov/pubmed/)

Dependancies
============

* NCBI [entrez-direct](https://www.ncbi.nlm.nih.gov/news/02-06-2014-entrez-direct-released/)
* [csvkit](https://csvkit.readthedocs.io/)
* R packages:
    - [tidyverse](https://github.com/tidyverse/tidyverse)
    - [plotly](https://github.com/ropensci/plotly)


Usage
=====

Run the following command for test:
```bash
bash run.sh 'Regev, Aviv'
```

Then you could see a folder called `regev` (the family name of the specified
author) in the current directory, the output images are `regev.pdf` and
`regev.html` in that folder.

Example
=======

![publications (Regev)](example/regev.png?raw=true "Publications in pubmed - Aviv Regev")

