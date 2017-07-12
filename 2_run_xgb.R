#------------------------------------------------------------------------------------
# Extreme Gradient Boosting
#   1. Set hyperparameters based on crOss validation
#   2. Transform the dataset to sparse matrix
#   3. Run xgb and compute accuracy
#------------------------------------------------------------------------------------

eta = 0.001	
max_depth = 2	
subsample = 0.1	
colsample_bytree= 1	
early_stopping_rounds = 100

run_xgb <- function(x_train,y_train,x_test,y_test){
  print("Running XGBoost......")
  
  xgb_train = data.frame(sapply(x_train,as.numeric))
  xgb_train$TARGET = as.numeric(as.character(y_train))
  xgb_train = sparse.model.matrix(TARGET ~ ., data = xgb_train)
  
  dtrain = xgb.DMatrix(data = xgb_train, label= as.numeric(as.character(y_train)))
  
  watchlist = list(train=dtrain)
  
  param = list(  objective           = "binary:logistic", 
                 booster             = "gbtree",
                 eval_metric         = "auc",
                 eta                 = eta,
                 max_depth           = max_depth,
                 subsample           = subsample,
                 colsample_bytree    = colsample_bytree
  )
  
  
  model = xgb.train(   params               = param, 
                        data                = dtrain, 
                        nrounds             = 200, 
                        verbose             = 1,
                        watchlist           = watchlist,
                        maximize            = FALSE,
                        early_stopping_rounds = early_stopping_rounds
  )
  
  
  xgb_test = data.frame(sapply(x_test,as.numeric))
  xgb_test$TARGET = y_test
  test = sparse.model.matrix(TARGET ~ ., data = xgb_test)
  preds = round(predict(model, test,classification=T))
  return(sum(y_test==preds)*100/length(y_test))
  
}