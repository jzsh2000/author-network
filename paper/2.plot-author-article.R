library(tidyverse)

plot_article <- function(author) {
    read_csv("../database/journal-IF-medline.csv") %>%
        inner_join(read_tsv(file.path(author,
                                      paste0(author, '.tsv'))),
                   by = c('JournalTitle' = 'Title')) %>%
        ggplot(aes(x = ImpactFactor, y = Count)) +
            geom_bar(stat = 'identity') +
            theme_bw()
    ggsave(file.path(author,
                     paste0(author, '.pdf')))
}

args = commandArgs(trailingOnly = TRUE)
author = ifelse(length(args) == 0, 'regev', args[1])

plot_article(author)
