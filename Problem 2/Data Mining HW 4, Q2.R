library(skimr)
social_marketing <- read.csv("https://raw.githubusercontent.com/jgscott/ECO395M/master/data/social_marketing.csv")
str(social_marketing)
skim(social_marketing)

summary(social_marketing)

cor(social_marketing[,2:37])

library(GGally)
ggcorr(social_marketing[,2:37])

table(social_marketing$spam, social_marketing$adult)
table(social_marketing$adult)
prop.table(table(social_marketing$spam, social_marketing$adult))

# Dropping all observations marked with spam
SM_spam_free <- social_marketing[!(social_marketing$spam > "0"),]

# Checking to see if all observations with spam were dropped
table(SM_spam_free$spam)

# Dropping the spam variable
SM <- SM_spam_free[-c(36)]

# Number of users and the amount of adult content they posted
table(SM$adult)
prop.table(table(SM$adult))

sum(SM$adult)

# Find row summery of total tweet count for each user
rs <- rowSums(SM[,-1])

# Drop users with who have more than 25% of total tweets related to adult content
rs_2 <- SM[SM$adult/rs<.25,]
SM <- rs_2

library(dplyr)
library(tidyr)
# Check
SM %>% 
  group_by(adult, X) %>%
  # Count occurences of adult flagged tweets per user
  summarise(n=n()) %>%
  # Get percentage per user
  mutate(percent = n / sum(n)*100) %>%
  filter(percent>20) %>%
  select(X, adult, percent) %>%
  arrange(desc(adult))

#----PCA----#
# Drop users variable X
SM2 <- SM

# Check distribution for SM2
SM2 %>% 
  gather(Variable, Value) %>% 
  ggplot(aes(x=Value, fill=Variable)) +
  geom_density(alpha=0.3) +
  geom_vline(aes(xintercept=0)) +
  theme_bw()

# PCA
SM_pca <- prcomp(SM2[,-c(1,10)],
                 scale. = TRUE,
                 center = TRUE)

str(SM_pca)

print(SM_pca)

plot(SM_pca, type = 'l') 

SM_pcaDF <- data.frame(SM_pca$x)

plot(SM_pcaDF[,1:5], pch = 16, col=rgb(0,0,0, alpha = .5), cex =.3)

# Summary to find what percent of variation is explained by each PCA 
summary(SM_pca)

# Plot of PCA
library(ggplot2)
library(ggfortify)
ggplot2::autoplot(SM_pca, loadings = TRUE, label.size = 3, loadings.label = TRUE, loadings.colour = 'red', loadings.label.colour = "blue")

# Find loadings
loadings = SM_pca$rotation

# these are the 10 tweet groups most negatively associated with Nutrient H20 followers
loadings[,1] %>% sort %>% head(10)

# these are the 10 tweet groups most positively associated with Nutrient H20 followers
loadings[,1] %>% sort %>% tail(10)

#----Hierarchical Clustering the PCA's for market segmentation----#
x = loadings[,1]
y = loadings[,2:8]

# Cluster and graphing
# Market segementation using the PCA's 1-8
hc = hclust(dist(cbind(x,y)), method = 'ward.D')
plot(hc, axes=F, xlab='Twitter Categories', ylab='Market Segmentation', sub ='', main='Clustering of Principle Components 1-8')
rect.hclust(hc, k=6, border='red')
