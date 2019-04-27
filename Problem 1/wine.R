# read in data
wine <- read.csv("https://raw.githubusercontent.com/jgscott/ECO395M/master/data/wine.csv")
# load packages
library(tidyverse)
library(ggplot2)
library(ggfortify) #for plotting pc1 and pc2
library(corrplot)
source("http://www.sthda.com/upload/rquery_cormat.r")

# principal component analysis for wine color
X = wine[,c(1:11)]
pc1 = prcomp(X, scale=TRUE, center=TRUE)
loadings = pc1$rotation
scores = pc1$x
summary(pc1) # statisitics about each component
biplot(pc1) # each wine's ID with chemical characteristics vectors
autoplot(pc1) # a closer look with just the data points
# revealing the colors associated for each group (checking work)
qplot(scores[,1], scores[,2], color=wine$color, xlab='Component 1', ylab='Component 2')
# seeing how PCA performed
# PCAcluster = kmeans(scores[,1:4], 2, nstart=25)
# xtabs(~PCAcluster$cluster + wine$color)

# correlation matrix for next part
rquery.cormat(X)
# this allows us to identify correlations between chemicals

# k means clustering for wine color
X = scale(X, center=TRUE, scale=TRUE)
mu = attr(X,"scaled:center")
sigma = attr(X,"scaled:scale")
# run k-means with 2 clusters for each color
cluster1 = kmeans(X, 2, nstart=25)
# examining statistics in the 2 clusters
cluster1$center[1,]*sigma + mu
cluster1$center[2,]*sigma + mu
# random assortment of plots
qplot(volatile.acidity, alcohol, data=wine, color=factor(cluster1$cluster))
qplot(residual.sugar, pH, data=wine, color=factor(cluster1$cluster))
qplot(fixed.acidity, chlorides, data=wine, color=factor(cluster1$cluster))
qplot(total.sulfur.dioxide, density, data=wine, color=factor(cluster1$cluster))
qplot(alcohol, density, data=wine, color=factor(cluster1$cluster))

# k means performance using supervised info
xtabs(~cluster1$cluster + wine$color)
      
# 1 is red, 2 is white
################################################################################

# k-means for wine quality
summary(wine$quality)
# quality ranges between 3 and 9; therefore there are 7 clusters that the wine can fall in
# all are pretty much useless
cluster2 = kmeans(X, 7, nstart=25)
qplot(volatile.acidity, alcohol, data=wine, color=factor(cluster2$cluster))
qplot(residual.sugar, pH, data=wine, color=factor(cluster2$cluster))
qplot(fixed.acidity, chlorides, data=wine, color=factor(cluster2$cluster))
qplot(total.sulfur.dioxide, density, data=wine, color=factor(cluster2$cluster)) # interesting
# evidence against quality prediction for k-means
xtabs(~cluster2$cluster + wine$quality)

# principal component analysis for wine quality
pc2 = kmeans(scores[,1:11], 7, nstart=25)
# clustered into 7 groups
qplot(scores[,1], scores[,2], color=factor(pc2$cluster), xlab='Component 1', ylab='Component 2')
# indicates that it was unable to cluster by quality (checking work)
qplot(scores[,1], scores[,2], color=factor(wine$quality), xlab='Component 1', ylab='Component 2')
