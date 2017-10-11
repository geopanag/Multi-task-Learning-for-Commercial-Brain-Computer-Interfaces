#------------------------------------------------------------------------------------
# The pipeline to run conventional algorithms in both datasets, with 10-fold cv
#    1. Load Datesets
#    2. Subset the data in cross validation folds based on subjects
#    3. Train and test each algorithm on that respective subsets 
#    4. Store the results
#------------------------------------------------------------------------------------

setwd("Path")


libs<-c("rnn","reshape2","ggplot2","RSNNS","pROC","neuralnet",
        "randomForest","xgboost","Matrix","data.table","e1071","caret","dplyr")

suppressPackageStartupMessages(sapply(libs,require,character.only = T))

source("Code/2_run_caret_classifier.R")
source("Code/2_run_xgb.R")


set.seed(2017)

cross_val_size = 10

##------------ Perform the experiments in all datasets
for(dataset in c("cmu","berkeley","berkeley1","berkeley2","berkeley3")){ #,"
  dat = read.csv(paste0("Data/",dataset,".csv"))
  
  len = length(unique(dat$Subject))/cross_val_size
  folds = list() #createFolds(factor(unique(dat$Subject)),k=cross_val_size)
  idx=1
  for(i in 1:cross_val_size){
    folds[i] = list(unique(dat$Subject)[idx:(idx+len-1)])
    idx = idx+len
  }
  
  ##------------ Matrix to keep the outcomes of the tests
  classifiers = c("LDA","sLDA","SVM","MLP","RBF_NN","LVQ","KNN1","Ensemble","Tree","RF","XGB")
  results_acc = data.frame(matrix(ncol=length(classifiers),nrow=cross_val_size))
  names(results_acc)  = classifiers
  
  
  for(f in seq_along(folds)){
    
    total_fold = proc.time()
    
    print("---------------------------------------")
    print(paste0(" In fold:",f))
    
    test = dat %>% dplyr::filter(Subject %in% unlist(folds[f]))
    train = dat %>% dplyr::filter(Subject %in% unlist(folds[-f]))
    
    print("subjects in test:")
    print(unique(test$Subject))
    
    
    ##------------ Store the data subsets to perform the rest of the experiments on them
    write.csv(train,paste0("path/to/train/",dataset,"_",f,".csv"),row.names=F)
    write.csv(test,paste0("path/to/test/",dataset,"_",f,".csv"),row.names=F)
    
    
    y_train=as.factor(train$Label)
    x_train= train %>% dplyr::select(-Subject,-Label)
    
    y_test = as.factor(test$Label)
    x_test = test %>% dplyr::select(-Subject,-Label)
    
    
    ##------------ LDA
    lda_acc = run_caret_classifier(x_train,y_train,x_test,y_test,"lda","")
    if(!is.na(lda_acc)){
      results_acc[f,"LDA"]  = format(round(lda_acc, 3), nsmall = 3)
    }else{
      print("NA here ")
    }
    
    ##------------ shrinkage LDA
    
    pda_acc = run_caret_classifier(x_train,y_train,x_test,y_test,"pda","")
    if(!is.na(pda_acc)){
      results_acc[f,"sLDA"]  = format(round(pda_acc, 3), nsmall = 3)
    }else{
      print("NA here ")
    }
    
    ##------------ linear SVM
    
    svm_acc = run_caret_classifier(x_train,y_train,x_test,y_test,"svmLinear","")
    if(!is.na(svm_acc)){
      results_acc[f,"SVM"]  = format(round(svm_acc, 3), nsmall = 3)
    }else{
      print("NA here ")
    }
    
    ##------------ Multi layer Perceptron
    
    mlp_acc = run_caret_classifier(x_train,y_train,x_test,y_test,"mlp","")
    if(!is.na(mlp_acc)){
      results_acc[f,"MLP"]  = format(round(mlp_acc, 3), nsmall = 3)
    }else{
      print("NA here ")
    }
    
    ##------------ Rbf NN
    
    rbf_acc = run_caret_classifier(x_train,y_train,x_test,y_test,"rbf","")
    if(!is.na(rbf_acc)){
      results_acc[f,"RBF_NN"]  = format(round(rbf_acc, 3), nsmall = 3)
    }else{
      print("NA here ")
    }
    
    ##------------ LVQ
    
    lvq_acc = run_caret_classifier(x_train,y_train,x_test,y_test,"lvq",
                                   paste0("Data/experiments/feature_selection/importance/",
                                          dataset,"_",f,"_lvq.csv"))
    if(!is.na(lvq_acc)){
      results_acc[f,"LVQ"]  = format(round(lvq_acc, 3), nsmall = 3)
    }else{
      print("NA here ")
    }
    
    ##------------ KNN
    
    knn_acc = run_caret_classifier(x_train,y_train,x_test,y_test,"knn3","")
    if(!is.na(knn_acc)){
      results_acc[f,"KNN1"]  = format(round(knn_acc, 3), nsmall = 3)
      
    }else{
      print("NA here ")
    }
    
    
    ##------------ Tree
    
    tree_acc = run_caret_classifier(x_train,y_train,x_test,y_test,"rpart","")
    if( !is.na(tree_acc)){
      results_acc[f,"Tree"] = format(round(tree_acc, 3), nsmall = 3)
    }else{
      print("NA here ")
    }
    
    ##------------ RandomForest
    
    rf_acc = run_caret_classifier(x_train,y_train,x_test,y_test,"randomForest",
                                  paste0("Data/experiments/feature_selection/importance/",
                                         dataset,"_",f,"_rf.csv"))
    
    if( !is.na(rf_acc) ){
      results_acc[f,"RF"] = format(round(rf_acc, 3), nsmall = 3)
    }else{
      print("NA here ")
    }
    
    # ##------------ XG boost
    
    xgb_acc = run_xgb(x_train,y_train,x_test,y_test)
    if( !is.na(xgb_acc)){
      results_acc[f,"XGB"] = format(round(xgb_acc, 3), nsmall = 3)
    }else{
      print("NA here ")
    }
    
    # ##------------ Ensemble
    
    enn_acc = run_caret_classifier(x_train,y_train,x_test,y_test,"ensemble_nn","")
    if( !is.na(enn_acc)){
      results_acc[f,"Ensemble"] = format(round(enn_acc, 3), nsmall = 3)
    }else{
      print("NA here ")
    }
    
    print("total fold time:")
    print(proc.time() - total_fold)
    
    
  }
  
  write.csv(results_acc,paste0("Data/experiments/conventional_results/",dataset,"_acc.csv"),row.names=F)
  
  
}
