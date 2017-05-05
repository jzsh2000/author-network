library(tidyverse)
library(stringr)
library(networkD3)

node <- read_csv('network/node.csv')
edge <- read_csv('network/edge.csv')

edge.name = str_split_fixed(edge$link, fixed(' (co) '), n = 2)
edge <- set_names(as_data_frame(cbind(edge.name, edge$size)),
                  c('source', 'target', 'size')) %>%
    mutate(source = match(source, node$id) - 1,
           target = match(target, node$id) - 1)

forceNetwork(Links = edge,
             Nodes = node,
             Source = "source",
             Target = "target",
             Value = "size",
             NodeID = "fau",
             Nodesize = "size",
             Group = "size",
             radiusCalculation = JS("Math.sqrt(d.nodesize) * 8"),
             charge = -150,
             linkColour = '#CCC',
             opacity = 0.9,
             legend = TRUE,
             bounded = TRUE,
             opacityNoHover = 0.8
             ) %>%
    saveNetwork(file.path(getwd(), 'network/network.html'))
