#############################################################################
# Dummify Categorical Variables
#############################################################################
movies <- readRDS("movies02.rds")

cate_features <- names(movies)[1:3]
sub_movies <- movies[, cate_features] 
dummies <- dummyVars(~ ., data = sub_movies, moviesRank = T)
dummies.df <- as.data.frame(predict(dummies, sub_movies))
movies <- cbind(movies, dummies.df)

tidy.name.vector <- make.names(colnames(movies), unique = TRUE)
names(movies) <- tidy.name.vector
movies$genre <- NULL
movies$critics_rating <- NULL
movies$audience_rating <- NULL

#############################################################################
# Remove Zero variance variables and high correlation variables
#############################################################################
# Remove highly correlated variables
high.cor <- findCorrelation(cor(movies[,c(-5)]), cutoff = .80)
high.cor.df <- movies[ ,high.cor]
movies <- movies[ ,-high.cor]

# Remove near zero variance variables
nzCol <- nearZeroVar(movies[,c(-5)], saveMetrics = TRUE)
nz.df <- movies[, nzCol$nzv == TRUE]
movies <- movies[, nzCol$nzv == FALSE]

saveRDS(movies, "./movies03_noCluster.rds")
movies <- readRDS("movies03_noCluster.rds")
#############################################################################
# Add Clustering Var
#############################################################################
library(flexclust) # kcca

ratio_ss = rep(0)
for (k in 1:8) {
     school_km = kmeans(movies[-c(6)], centers = k, nstart = 20)
     # Save the ratio between of WSS to TSS in kth element of ratio_ss
     ratio_ss[k] = school_km$tot.withinss/school_km$totss
}
# Make a scree plot with type "b" and xlab "k"
plot(ratio_ss, type = "b", xlab = "k")

# k = 3 is the best one.
full <- movies[-c(6)]
k = 3
kosDist = dist(full, method = "euclidean")
hierCluster = hclust(kosDist, method="ward.D") 
hs.ec = cutree(hierCluster, k = k)

kosDist = dist(full, method = "maximum")
hierCluster = hclust(kosDist, method="ward.D") 
hs.mx = cutree(hierCluster, k = k)

kosDist = dist(full, method = "manhattan")
hierCluster = hclust(kosDist, method="ward.D") 
hs.mh = cutree(hierCluster, k = k)

kosDist = dist(full, method = "canberra")
hierCluster = hclust(kosDist, method="ward.D") 
hs.can = cutree(hierCluster, k = k)

kosDist = dist(full, method = "binary")
hierCluster = hclust(kosDist, method="ward.D") 
hs.bin = cutree(hierCluster, k = k)

kosDist = dist(full, method = "minkowski")
hierCluster = hclust(kosDist, method="ward.D") 
hs.mink = cutree(hierCluster, k = k)

set.seed(10)
KmeansCluster = kmeans(full, centers = k)
km.kcca = as.kcca(KmeansCluster, full)
km.full = predict(km.kcca)

full <- cbind(full, km.full, hs.mink, hs.bin, hs.can, hs.mh, hs.mx, hs.ec)
movies <- cbind(full, audience_score = movies[,c(6)])
saveRDS(movies, "./movies04_yesCluster.rds")

#############################################################################
# PCA
#############################################################################