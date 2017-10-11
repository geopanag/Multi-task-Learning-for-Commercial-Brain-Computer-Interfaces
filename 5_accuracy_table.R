#------------------------------------------------------------------------------------
# The pipeline to run conventional algorithms in both datasets, with 10-fold cv
#    1. Load the results from all experiments
#    2. Compute the average accuracy for berkeley subsets
#    3. Create a Latex table to include in the paper
#------------------------------------------------------------------------------------

setwd("Path/to/conventional_results")

library(xtable)
dat = matrix(nrow=0,ncol=11)

for( f in dir()){
  x = read.csv(f)
  dat = rbind(dat,sapply(x,mean))
}
dat = t(dat)

mtl = read.csv("../results_malsar.csv")

vec = t(mtl[,3])

dat = sapply(data.frame(rbind(dat,matrix(vec,ncol=5))),as.numeric)

dat[,2] = apply(dat[,2:4],1,mean,na.rm=T)
dat[,3] = dat[,5]


dat=data.frame(dat)
dat[,4:5]=NULL

rownames(dat)= c("Linear Discriminant Analysis  cite{lemm2011introduction}",
                  "Shrinkage Linear Discriminant Analysis cite{lemm2011introduction}",
                  "Linear Support Vector Machine  cite{lemm2011introduction}",
                  "Multi Layer Perceptron  cite{congedo2006classification}",
                  "Radial Basis Neural Network cite{kaper2004bci}",
                  "Learning Vector Quantization  cite{pfurtscheller1993brain}",
                  "K Nearest Neighbors cite{borisoff2004brain}",
                  "Tree",
                  "Random Forest",
                  "Extreme Boosting",
                  "Ensemble cite{qin2005ica}",
                  "Logistic $l_{21}$ cite{argyriou2008convex}",
                  "Elastic Net cite{kia2014multi}",
                  "Bayesian cite{alamgir2010multitask}")

names(dat) = c("CMU (9 subjects)", "Berkeley (10 subjects)","Berkeley (30 subjects)")
xtable(dat)
