#----------------------------------------------------------------------------------------------------------
# Plot Weights of Multi-task algorithms
#    1. For each dataset,fold and sparse weight algorithm, load the weights
#    2. Take the mean value of each weight for all subjects
#    3. Take the mean value for all folds and store it in the matrix to be ploted
#    4. Plot heatmap where the higher the weight the lighter the color
#----------------------------------------------------------------------------------------------------------

library(dplyr)
library(ggplot2)
library(plyr)
library(reshape2)

setwd("Data/experiments/feature_selection/mtl_weights")
files = dir()

dimensions = 9

datasets = c("cmu","berkeley")
folds = c(5,10)
algorithms = c("log_l21","log_lasso")

features = c( "Raw",
              "Delta",
              "Theta",
              "Alpha1",
              "Alpha2",
              "Beta1",
              "Beta2",
              "Gamma1",
              "Gamma2")

to_plot = data.frame(matrix(ncol=dimensions+3,nrow=0))

for(d in datasets){
  for(f in folds){
    heat = matrix(ncol=dimensions,nrow=0)
    for(a in algorithms){
      
      mean_w = matrix(ncol=dimensions,nrow=0)
      for(s in files){
        if(grepl(paste0(d,"_",f),s) & grepl(a,s)){
          
          weights = read.csv(s,header=F)
          
          if(dim(weights)[1]==9){
            weights = t(weights)
          }  
          
          mean_w = rbind(mean_w,sapply(data.frame(weights),mean))
          
        }
      }
      
      heat = rbind(heat,sapply(data.frame(mean_w),mean))
      
    }
    
    heat = data.frame(heat)
    
    heat$Algorithms = algorithms
    heat$fold = f
    heat$dataset = d
    
    to_plot = rbind(to_plot,heat)
  }
  
}

names(to_plot)[1:9] = features
to_plot[to_plot$dataset=="cmu","dataset"]="CMU"
to_plot[to_plot$dataset=="berkeley","dataset"]="Berkeley"
to_plot[to_plot$Algorithms=="log_l21","Algorithms"]="L21 Norm"
to_plot[to_plot$Algorithms=="log_lasso","Algorithms"]="Elastic Net"
to_plot[to_plot$Algorithms=="bayesian","Algorithms"]="Bayesian"
to_plot$fold = paste0(to_plot$fold,"-Fold")

heat.m = melt(to_plot,id.vars=c("Algorithms","fold","dataset"))


ggplot(data = heat.m, aes(x = variable, y = Algorithms)) +
  geom_tile(aes(fill = value))+xlab("Featuers")+ylab("Algorithms")+facet_grid(fold~dataset)+
  theme(axis.text.x = element_text(face = "bold", color = "black", size = 16,angle = 45, hjust = 1),
        axis.text.y = element_text(face = "bold", color = "black", size = 11,angle = 90, hjust = 1),
        axis.title.x = element_text(face = "bold", color = "black", size = 14),
        axis.title.y = element_text(face = "bold", color = "black", size = 14),
        strip.text.x =element_text(face = "bold", color = "black", size = 13),
        strip.text.y =element_text(face = "bold", color = "black", size = 13),legend.position="none")+
  scale_fill_gradient(low = "black", high= "grey")

ggsave("../../../../figures/mtl_weights_heatmap.png")
