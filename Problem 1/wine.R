# read in data
wine <- read.csv("https://raw.githubusercontent.com/jgscott/ECO395M/master/data/wine.csv")
# create dummy for wine color
wine$colordummy <- ifelse(wine$color == 'red', 1, 0)

# principal component analysis
X = as.matrix(wine[,-1])
y = wine[,1]


# Plot a random sample of the NIR spectra
mu_x = colMeans(X)
nir_wavelength = seq(900, 1700, by=2)
par(mfrow=c(2,2))
for(i in sample.int(nrow(X), 4)) {
  plot(nir_wavelength, X[i,] - mu_x, main=i, ylim=c(-0.1,0.1))
}

# They all differ from the mean in very structured ways
# Extremely strong collinearity among the predictor variables
sigma_X = cor(X)
sigma_X[1:10,1:10]


# Let's try dimensionality reduction via PCA
pc_wine = prcomp(X, scale=TRUE)

# pc_wine$x has the summary variables
# Regress on the first K
K = 3
scores = pc_wine$x[,1:K]
pcr1 = lm(y ~ scores)

summary(pcr1)

# Show the model fit
plot(fitted(pcr1), y)

# Visualize the first few principal components:
# these are the coefficients in the linear combination for each summary
plot(nir_wavelength, pc_gasoline$rotation[,1], ylim=c(-0.15,0.15))
plot(nir_wavelength, pc_gasoline$rotation[,2], ylim=c(-0.15,0.15))
plot(nir_wavelength, pc_gasoline$rotation[,3], ylim=c(-0.15,0.15))

################################################################################
# k means clustering
# get rid of color (which is not numeric) to allow scaling
wine$color <- NULL
wine_scaled <- scale(wine, center=TRUE, scale=TRUE) 

## first, consider just red and white meat
alcohol_quality = wine_scaled[,c("alcohol","quality")]
head(alcohol_quality)
plot(alcohol_quality)


# Use k-means to get 3 clusters
cluster_alcoholQuality <- kmeans(alcohol_quality, centers=3)

# plot with labels
plot(alcohol_quality, xlim=c(-5,5), 
     type="n", xlab="% Alcohol", ylab="Quality (Score)")  
text(alcohol_quality, labels=rownames(alcohol_quality), 
     col=rainbow(3)[cluster_alcoholQuality$cluster])

## same plot, but now with clustering on all protein groups
## change the number of centers to see what happens.
cluster_all <- kmeans(wine_scaled, centers=7, nstart=50)
names(cluster_all)

# Extract some of the information from the fitted model
cluster_all$centers
cluster_all$cluster

# Plot the clustering on the red-white meat axes
plot(wine_scaled[,"alcohol"], wine_scaled[,"quality"], xlim=c(-2,2.75), 
     type="n", ylab="Quality (score)", xlab="% Alcohol")
text(wine_scaled[,"alcohol"], wine_scaled[,"quality"], labels=rownames(wine), 
     col=rainbow(7)[cluster_all$cluster])
