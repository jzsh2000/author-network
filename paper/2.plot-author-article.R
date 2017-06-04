library(tidyverse)
library(stringr)
library(lubridate)
library(forcats)

library(plotly)
library(htmlwidgets)

# TODO: Add information of first author/corresponding author
# TODO: Show article title and number of citations
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
        mutate(IF_group = fct_rev(factor(ImpactFactor %/% 5 * 5))) %>%
        mutate(year = year(date)) %>%
        arrange(date)

    author_journal_info %>%
        ggplot(aes(x = year, y = 1, fill = IF_group)) +
            geom_bar(stat = 'identity') +
            ylab('publications') +
            scale_x_continuous(breaks = full_seq(range(author_journal_info$year),
                                                 period = 1)) +
            theme_bw()

    ggsave(filename = file.path(author, paste0(author, '.pdf')))

    author_journal_info %>%
        rename(journal = journal_title) %>%
        ggplot(aes(x = year, y = 1, fill = IF_group,
                   date = date, journal = journal)) +
            geom_bar(stat = 'identity') +
            ylab('publications') +
            scale_x_continuous(breaks = full_seq(range(author_journal_info$year),
                                             period = 1)) +
            theme_bw()

    saveWidget(widget = ggplotly(tooltip = c('date', 'journal')),
               file = file.path(getwd(), author, paste0(author, '.html')))

}

args = commandArgs(trailingOnly = TRUE)
author = ifelse(length(args) == 0, 'regev', args[1])

plot_article(author)
