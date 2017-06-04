library(tidyverse)
library(stringr)
library(lubridate)
library(forcats)

plot_article <- function(author) {
    journal_info <- read_csv("../database/journal-IF-medline.csv",
                             col_types = 'cccd') %>%
        select(-c(MedAbbr, NlmId))

    author_journal <- read_tsv(file.path(author,
                                         paste0(author, '.tsv')),
                               col_types = 'iccc') %>%
        mutate(date = ymd(str_extract(date, '^[^ ]*')))

    author_journal_info <- author_journal %>%
        inner_join(journal_info,
                   by = c('journal_title' = 'JournalTitle')) %>%
        arrange(date)

    author_journal_info %>%
        mutate(IF_group = fct_rev(factor(ImpactFactor %/% 5 * 5))) %>%
        mutate(year = year(date)) %>%
        ggplot(aes(x = year, y = 1, fill = IF_group)) +
            geom_bar(stat = 'identity') +
            ylab('publications') +
            scale_x_continuous(breaks = seq(from = 2002, to = 2017, by = 1)) +
            theme_bw()

    ggsave(file.path(author,
                     paste0(author, '.pdf')))
}

args = commandArgs(trailingOnly = TRUE)
author = ifelse(length(args) == 0, 'regev', args[1])

plot_article(author)
