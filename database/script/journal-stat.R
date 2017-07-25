#!/usr/bin/env Rscript

suppressWarnings(suppressMessages(library(tidyverse)))
suppressMessages(library(stringr))

args = commandArgs(TRUE)
database_file = args[1]
medline_file = args[2]

# write csv to stdout, can be piped to a file
str_subset(read_lines(medline_file), '^JID') %>%
    str_sub(start = 7) %>%
    table() %>%
    enframe() %>%
    rename(NlmId = name) %>%
    inner_join(read_csv(database_file,
                        col_types = 'cccd'), by = "NlmId") %>%
    arrange(desc(ImpactFactor)) %>%
    select(JournalTitle, ImpactFactor, value) %>%
    rename(Count=value) %>%
    format_csv() %>%
    cat()
