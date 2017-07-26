args = commandArgs(TRUE)
dat1 <- read.csv(args[1], stringsAsFactors = FALSE)
dat2 <- read.delim(args[2],
                   colClasses = c('character', 'character'),
                   stringsAsFactors = FALSE)

dat = merge(dat1, dat2,
            by.x = 'NlmId', by.y = 'journal_id', all.x = TRUE, sort = FALSE)
dat$count[is.na(dat$count)] = ''
names(dat)[which(names(dat) == 'count')] = 'Count.core'
dat = dat[order(-dat$ImpactFactor),]
write.csv(dat, row.names = FALSE)
