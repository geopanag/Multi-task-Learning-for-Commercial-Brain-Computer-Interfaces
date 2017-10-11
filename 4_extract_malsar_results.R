#----------------------------------------------------------------------------------------------------------
# Manage MALSAR results 
#   1. Read the predictions and labels produced by the matlab scripts for all datasets and algorithms
#   2. Compute accuracy of each fold
#   3. Take the mean accuracy for each setting and store it
#----------------------------------------------------------------------------------------------------------

library(dplyr)
setwd("Path/to/mtl_results")
files = dir()

results_table = data.frame(matrix(nrow=0,ncol=3))
names(results_table) = c("Dataset_Folds","Algo","Acc")


idx = 1

datasets = c("cmu","berkeley","berkeley1","berkeley2","berkeley3")
algorithms = c("log_l21","bayesian")

##------------------
for(d in datasets){
  for(a in algorithms){
    
    results=c()
    ##------------------ Load the results of each fold and compute accuracy
    for(s in files){
      if(grepl(paste0(d,"_"),s) & grepl(a,s)){
        print(s)
        
        dat = read.csv(s,header=F)    
        y_test = dat[,1]
        dat[,1] = NULL
        
        dat = data.frame(sapply(dat,sign))
        dat[dat==-1] = 0
        if(ncol(dat)>1){
          print("error")
        }
        
        results = c(results,c(sum(y_test==dat[,1])*100/length(y_test)))
      }
    }
    
    ##---------------- Store the mean accuracy of all folds
    result = as.numeric(format(round(mean(results), 3), nsmall = 3))
    results_table[idx,1:2] = c(paste0(d,"_"),a)
    results_table[idx,3]=result
    idx = idx+1
    
  }
}


write.csv(results_table,"../results_malsar.csv",row.names=F)
