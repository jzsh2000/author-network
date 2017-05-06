suppressMessages(library(tidyverse))
library(stringr)
library(networkD3)

node <- read_csv('network/node.csv', col_types = "cci")
edge <- read_csv('network/edge.csv', col_types = "ci")

# Set the parameter as a threshold of node size, if this parameter isn't set,
# retain 20 most important nodes.
args = commandArgs(trailingOnly = TRUE)
minsize = ifelse(length(args) == 0, NA, as.integer(args[1]))

if (is.na(minsize)) {
    node = node %>%
        filter(min_rank(desc(size)) <= 20) %>%
        arrange(desc(size))
} else {
    node = node %>%
        filter(size >= minsize) %>%
        arrange(desc(size))
}

edge.name = str_split_fixed(edge$link, fixed(' (co) '), n = 2)
edge.valid = (edge.name[,1] %in% node$id) & (edge.name[,2] %in% node$id)
edge <- set_names(as_data_frame(cbind(edge.name[edge.valid,],
                                      edge$size[edge.valid])),
                  c('source', 'target', 'size')) %>%
    mutate(source = match(source, node$id) - 1,
           target = match(target, node$id) - 1)

cat(sprintf('%03d nodes\n', nrow(node)))
cat(sprintf('%03d edges\n', nrow(edge)))

forceNetwork(Links = as.data.frame(edge),
             Nodes = as.data.frame(node),
             Source = "source",
             Target = "target",
             Value = "size",
             NodeID = "fau",
             Nodesize = "size",
             Group = "size",
             fontSize = 14,
             radiusCalculation = JS("Math.sqrt(d.nodesize) * 4"),
             charge = -1000,
             linkColour = '#CCC',
             opacity = 0.9,
             legend = TRUE,
             opacityNoHover = 0.8
             ) %>%
    saveNetwork(file.path(getwd(), 'network/network.html'))
