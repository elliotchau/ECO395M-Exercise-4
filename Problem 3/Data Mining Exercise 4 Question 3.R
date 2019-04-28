#Exercise 4 Question 3 
library(tidyverse)
library(arules)  # has a big ecosystem of packages built around it
library(arulesViz)

groceries_raw = read.csv("https://raw.githubusercontent.com/jgscott/ECO395M/master/data/groceries.txt", header = FALSE)

groceries_raw$ID = seq.int(nrow(groceries_raw))

grocery <- cbind(groceries_raw[,5], stack(lapply(groceries_raw[,1:4], as.character)))[1:2]
colnames(grocery) <- c("ID","items")
grocery <- grocery[order(grocery$ID),]
grocery <- grocery[!(grocery$items==""),]
row.names(grocery) <- 1:nrow(grocery)
grocery$ID = factor(grocery$ID)

#split 
grocerlist = split(x=grocery$items, f=grocery$ID)

grocerlist = lapply(grocerlist, unique)
grocertrans = as(grocerlist, "transactions")

summary(grocertrans)

groceryrules = apriori(grocertrans, 
                     parameter=list(support=.01, confidence=.1, maxlen=5))


# Look at the output... so many rules!
inspect(groceryrules)

## Choose a subset
inspect(subset(groceryrules, lift > 5))
inspect(subset(groceryrules, confidence > 0.6))
inspect(subset(groceryrules, lift > 10 & confidence > 0.5))

# plot all the rules in (support, confidence) space
# notice that high lift rules tend to have low support
plot(groceryrules)

# can swap the axes and color scales
plot(groceryrules, measure = c("support", "lift"), shading = "confidence")

# "two key" plot: coloring is by size (order) of item set
plot(groceryrules, method='two-key plot')

# can now look at subsets driven by the plot
inspect(subset(groceryrules, support > 0.035))
inspect(subset(groceryrules, confidence > 0.6))

# graph-based visualization
sub1 = subset(groceryrules, subset=confidence > 0.01 & support > 0.005)
summary(sub1)
plot(sub1, method='graph')

plot(head(sub1, 100, by='lift'), method='graph')

# export a graph
saveAsGraph(sub1, file = "groceryrules.graphml")


