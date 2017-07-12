
%%
%   Run Multi task Logistic l21-norm 
%       1. Run the algorithm on the given data
%       2. Store the weights
%       3. Concatenate predictions and labels for each task into a lengthy
%          vector and store it
%%

function e3_log_21(x_train,y_train, x_test,y_test,opts,test_task_num,results_path,weights_path) 
  
    [W, c, funcVal] = Logistic_L21(x_train, y_train, 1, [opts]);
    
    csvwrite(weights_path,W);
    
    y_pred = [];
    labels = [];
    for t = 1: test_task_num
        y_pred = [y_pred ; x_test{t}*mean(W,2)];
        labels = [labels ; y_test{t}];
    end
    
    
    csvwrite(results_path,[labels y_pred]);
end    