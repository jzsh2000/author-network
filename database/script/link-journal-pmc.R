library(tidyverse)
library(stringr)

# input : medline-Journal-IF.csv
#         jlist.csv
# Output: pmc-Journal-IF.csv (only deep cooperative journals)

# ===== read data
pmc <- read_csv('jlist.csv',
                col_types = 'c___c___ccc_c') %>%
    filter(`Free access` == 'Immediate',
           `Open access` == 'All',
           `Participation level` == 'Full') %>%
    mutate(`PmcId` = str_extract(`Journal URL`,
                                          '[0-9]+(?=/$)')) %>%
    select(`Journal title`, Publisher, `PmcId`)

medline_IF <- read_csv('medline-Journal-IF.csv',
                       col_types = 'cccd')

# ===== write data
pmc %>%
    rename(JournalTitle = `Journal title`) %>%
    inner_join(medline_IF, by = 'JournalTitle') %>%
    arrange(desc(ImpactFactor)) %>%
    write_csv('journal-IF-pmc.csv')
