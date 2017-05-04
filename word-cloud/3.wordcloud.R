library(tidyverse)
library(wordcloud)

plot_wordcloud <- function(author, word_num) {
    word <- read_tsv(file.path(author,
                               paste0(author, '.word.clean.txt'))) %>%
        filter(min_rank(desc(freq)) <= word_num)
    pdf(file.path(author, paste0(author, '.pdf')))
    wordcloud(words = word$word, freq = word$freq,
              min.freq = 1,
              random.order = FALSE,
              random.color = TRUE,
              colors = brewer.pal(9, "Set1"))
    dev.off()
}

args = commandArgs(trailingOnly = TRUE)
author = ifelse(length(args) == 0, 'regev', args[1])
word_num = ifelse(length(args) < 2, 80, as.integer(args[2]))
plot_wordcloud(author, word_num)
