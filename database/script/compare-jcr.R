library(tidyverse)
library(scales)

jcr.2015 <- read_csv('jcr/JournalHomeGrid-2015.csv',
                quote = '\"',
                col_types = 'iccdd',
                na = 'Not Available') %>%
    select(name = `Full Journal Title`,
           IF.2015 = `Journal Impact Factor`) %>%
    unique() %>%
    drop_na()

jcr.2016 <- read_csv('jcr/JournalHomeGrid-2016.csv',
                     quote = '\"',
                     col_types = 'iccdd',
                     na = 'Not Available') %>%
    select(name = `Full Journal Title`,
           IF.2016 = `Journal Impact Factor`) %>%
    unique() %>%
    drop_na()

jcr <- inner_join(jcr.2015, jcr.2016, by = 'name') %>%
    filter(IF.2015 >= 1, IF.2016 >= 1) %>%
    mutate(increment = IF.2016 - IF.2015)

jcr %>%
    # filter(abs(increment) >= 1.5) %>%
    ggplot(aes(x = IF.2016,
               y = IF.2016 / IF.2015,
               IF.2015 = IF.2015,
               name = name)) +
        scale_x_continuous(
            breaks = c(1,2,4,8,16,32,64,128),
            trans = log2_trans()) +
        scale_y_continuous(
            breaks = c(0.25,0.33,0.5,1,2,3,4),
            trans = log2_trans()) +
        theme_bw() +
        geom_point(alpha = .6)
plotly::ggplotly(tooltip = c('x', 'IF.2015', 'name'))
