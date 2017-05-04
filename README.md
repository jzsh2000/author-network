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

3. run python script

    In bash (here is an example):
    ```bash
    python network.py 27549193 "Li, Bo"
    ```

    The number `27549193` is a pubmed article id, and "Li, Bo" is the full name
    of the first author of that article. If the last parameter is not set, the
    first author will be chosen.

    After running this command, a folder called 'network' will be generated in
    the current directory. There should be three files in that folder,
    `network.sif`, `node.csv` and `edge.csv`, and they can be imported to
    [cytoscape](http://www.cytoscape.org/) for visualization. See the files in
    directory 'example' for more details.
