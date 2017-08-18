#------------------------------------------------------------------------------------
# Run the respective algorithm on the given data and compute the accuracy
#------------------------------------------------------------------------------------

run_caret_classifier <- function(x_train,y_train,x_test,y_test,classifier,path){
  
  print(paste0("Running ",classifier,"......"))
  
  if(classifier=="mlp"){
    model = mlp(x_train,as.numeric(y_train))
    preds = predict(model,x_test)
    preds = as.numeric(preds>mean(preds))
    
  }else if(classifier=="rbf"){
    model = rbf(x_train,as.numeric(y_train),metric="Accuracy")
    preds = predict(model,x_test)
    preds = as.numeric(preds>mean(preds))
    
  }else if(classifier=="knn3"){
    model = knn3(x_train,y_train,k=1)
    preds = round(predict(model,x_test)[,2])
    
  }else if(classifier=="randomForest"){
    model = randomForest(x_train,y_train,importance = T)
    preds = as.numeric(as.character(predict(model,x_test)))
    
    imp = as.numeric(t(varImp(model,type=1, scale=TRUE)))
    
    fileConn = file(path)
    writeLines(paste(imp,collapse=","), fileConn)
    close(fileConn)
  
  }else if(classifier=="ensemble_nn"){
    iterations = 10
    model = avNNet(x_train, y_train, repeats = iterations, bag = T,
                   allowParallel = TRUE, seeds = sample.int(iterations), size=10)
    preds = as.numeric(as.character(predict(model, x_test,type="class")))
  }else{
    
    model = train(x_train,y_train,method = classifier,metric="Accuracy")
    
    if(classifier=="lvq"){
      fileConn = file(path)
      writeLines(paste(varImp(model,type=1,scale=T)$importance[,1]  ,collapse=","), fileConn)
      close(fileConn)
    }
    
    preds = as.numeric(as.character(predict(model,x_test)))
  
  }
  y_test = as.numeric(as.character(y_test))
  
  return(sum(y_test==preds)*100/length(y_test))
  
}