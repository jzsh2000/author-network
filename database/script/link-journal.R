library(tidyverse)
library(stringr)

# input : J_Medline.tsv
#         JournalHomeGrid.csv
# Output: medline-Journal-IF.csv

# ===== read data
medline <- read_tsv('J_Medline.tsv',
                    quote = '',
                    col_types = 'icccccc') %>%
    select(JournalTitle, MedAbbr, IsoAbbr, NlmId)

clean_string <- function(string) {
    str_to_lower(str_replace_all(string, '[^A-Za-z]+', ' '))
}

jcr <- read_csv('JournalHomeGrid.csv',
                quote = '\"',
                col_types = 'iccdd',
                na = 'Not Available') %>%
    select(JCR_name = `Full Journal Title`,
           IF = `Journal Impact Factor`) %>%
    unique() %>%
    drop_na() %>%
    mutate(JCR_name_lowcase = map_chr(JCR_name, clean_string))

# ===== match two datasets
medline2jcr <- pmap_int(list(medline$JournalTitle,
                         medline$MedAbbr,
                         medline$IsoAbbr),
                    function(jt, ma, ia) {
                        id = match(map_chr(jt, clean_string),
                                   jcr$JCR_name_lowcase)
                        if (is.na(id)) {
                            id = match(map_chr(ma, clean_string),
                                       jcr$JCR_name_lowcase)
                            if (is.na(id)) {
                                id = match(map_chr(ia, clean_string),
                                           jcr$JCR_name_lowcase)
                            }
                        }
                        id
                    })

medline_IF = bind_cols(medline[!is.na(medline2jcr),],
                       jcr[na.omit(medline2jcr),] %>% select(JCR_name, IF)) %>%
    # MedAbbr is a short form of the full journal title; it is assigned whether
    # the title is a MEDLINE journal or not.
    filter(!is.na(MedAbbr)) %>%
    arrange(desc(IF))
medline_IF %>%
    select(JournalTitle, MedAbbr, NlmId, IF) %>%
    rename(ImpactFactor = IF) %>%
    write_csv('journal-IF-medline.csv')
