library(tidyverse)
library(stringr)

args = commandArgs(trailingOnly = TRUE)
author = ifelse(length(args) < 2, 'regev', args[1])
author_fullname = ifelse(length(args) < 2, 'Regev, Aviv', args[2])

medline <- data_frame(
    text = read_lines(file.path(author, paste0(author, '.txt')))
) %>%
    mutate(PMID = str_extract(text, '(?<=^PMID- )[0-9]*')) %>%
    fill(PMID, .direction = 'down') %>%
    filter(text != '') %>%
    group_by(PMID) %>%
    nest(.key = 'text')

extract_multiple_line <- function(text_column, pattern) {
    map_chr(text_column, function(medline_text) {
        text = medline_text[[1]]
        idx_start = which(str_detect(text, pattern))
        idx_span = which(str_detect(text[-seq(idx_start)], '^[^ ]'))[1]
        paste(str_sub(text[seq(idx_start, (idx_start + idx_span - 1))],
                      start = 7),
              collapse = ' ')
    })
}

extract_single_line <- function(text_column, pattern) {
    map_chr(text_column, function(medline_text) {
        str_sub(
            str_subset(medline_text[[1]], pattern)[1],
            start = 7)
    })
}

medline %>%
    mutate(journal_title_abbr = extract_single_line(.$text, '^TA ')) %>%
    mutate(journal_title = extract_single_line(.$text, '^JT ')) %>%
    mutate(entrez_date = extract_single_line(.$text, '^EDAT')) %>%
    mutate(publication_type = map_chr(.$text, function(medline_text) {
        if_else(any(str_detect(
            string = medline_text[[1]], pattern = 'PT  - Review'
        )), 'review', 'article')
    }
    )) %>%
    mutate(author_type = map_chr(.$text, function(medline_text) {
        author_list = str_sub(str_subset(medline_text[[1]], '^FAU'), 7)
        index = match(author_fullname, author_list)
        if (is.na(index)) {return('unknown')}
        else if (index == 1) {return('first')}
        else if (index == length(author_list)) {return('corresponding')}
        else {return('other')}
    })) %>%
    mutate(title = str_replace_all(extract_multiple_line(.$text, '^TI '),
                                   '  *', ' ')) %>%
    select(-text) %>%
    write_tsv(file.path(author, paste0(author, '.tsv')))
