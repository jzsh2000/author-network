# usage

1. set your email address in environment variable 'EMAIL'. This variable will
   be used when fetching data from NCBI.

    In bash (**use your email address**):
    ```bash
    export EMAIL='example@example.com'
    ```

2. install the required python modules

    In bash:
    ```bash
    pip install -r requirements.txt
    ```

3. run python script `network.py`

    In bash (here is an example):
    ```bash
    python network.py 27549193 "Li, Bo"
    ```

    The number `27549193` is a pubmed article id, and "Li, Bo" is the full name
    of the first author of that article. If the last parameter is not set, the
    first author will be chosen.

    If you are confident that there is no duplicate name for the specified
    author in pubmed, the pubmed auticle id can be omitted. For example:
    ```bash
    python network.py "Yan, Xiyun"
    ```

    After running this command, a folder called 'network' will be generated in
    the current directory. There should be three files in that folder,
    `network.sif`, `node.csv` and `edge.csv`, and they can be imported to
    [cytoscape](http://www.cytoscape.org/) for visualization. See the files in
    directory 'example' for example output and the [rendered
    image](https://github.com/jzsh2000/author-network/blob/master/example/network.pdf).

4. generate interactive network using `networkD3.R`

    In bash:
    ```bash
    Rscript networkD3.R
    ```

    This R script will use related files (i.e. `node.csv` and `edge.csv`) in
    the 'network' directory, and generate a html file called `network.html` in
    it. Then this web page could be opened in any modern browser to show the
    final network. If anything goes wrong, you should first checkout that
    [tidyverse](https://github.com/tidyverse/tidyverse) and
    [networkD3](https://github.com/christophergandrud/networkD3) are installed
    in your R environment.

    Here is a live example: <https://rawgit.com/jzsh2000/author-network/master/example/network.html>
