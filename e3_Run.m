
%%
%   Run Multi task learning algorithms in both BCI datasets
%       1. Set hyperparamaters of the algorithms on default values
%       2. Run the algorithms on each cv fold of the dataset, based on 
%          the same folds conventional algorithms run on
%       3. Store predictions, labels and weights
%%

addpath(genpath('MALSAR/'));

rng(2017)

eval_func_str = 'eval_MTL_mse';
higher_better = false; % mse is lower the better.
% optimization options
opts = [];


opts.init = 0; % compute start point from data.
opts.tFlag = 1; % terminate after relative objective
% value does not changes much.
opts.tol = 0.00001; % tolerance.
opts.maxIter = 1000; % maximum iteration number of optimization.
%[W funcVal] = Least_Lasso(data_feature, data_response, lambda, opts);


%% Read data
files_train = dir('C:\Users\georg\Desktop\experiments\folds\train\*.csv');
files_test = dir('C:\Users\georg\Desktop\experiments\folds\test\*.csv');
numfids = length(files_train);


disp(numfids)
for K = 1:numfids
    disp("---------------------------")
    disp(K)
    
    train = dataset('File',strcat('experiments\folds\train\',files_train(K).name),'Delimiter',',');
    x_train={};
    y_train={};
    train_subjects = unique(train.Subject);
    for s = 1:size(train_subjects,1)
        x_train{s} = double(train(train.Subject==train_subjects(s),2:10));
        y_train{s} = double(train(train.Subject==train_subjects(s),11));
    end
    
    
    test = dataset('File',strcat('experiments\folds\test\',files_test(K).name),'Delimiter',',');
    x_test={};
    y_test={};
    
    
    test_subjects = unique(test.Subject);
    for s = 1:size(test_subjects,1)
        x_test{s} = double(test(test.Subject==test_subjects(s),2:10));
        y_test{s} = double(test(test.Subject==test_subjects(s),11));
    end
    
    test_task_num = length(x_test);
    
    %% Run algorithms
    
    %Logistic l21
    disp("Log L21")
    results_path = strcat("Data\experiments\mtl_results\",strrep(strrep(files_train(K).name,"_train",""),".csv","_log_l21.csv"));
    weights_path = strcat("Data\experiments\feature_selection\mtl_weights\",strrep(strrep(files_train(K).name,"_train",""),".csv","_log_l21.csv"));
    e3_log_l21(x_train,y_train, x_test,y_test,opts,test_task_num,results_path,weights_path) 
     
    %Logistic Lasso
    disp("Log Lasso")
    results_path = strcat("Data\experiments\mtl_results\",strrep(strrep(files_train(K).name,"_train",""),".csv","_log_lasso.csv"));
    weights_path = strcat("Data\experiments\feature_selection\mtl_weights\",strrep(strrep(files_train(K).name,"_train",""),".csv","_log_lasso.csv"));
    e3_log_lasso(x_train,y_train, x_test,y_test,opts,test_task_num,results_path,weights_path) 
    
    %Bayesian
    disp("Bayesian")
    results_path = strcat("Data\experiments\mtl_results\",strrep(strrep(files_train(K).name,"_train",""),".csv","_bayesian.csv"));
    e3_mtl_bayes(x_train,y_train, x_test,y_test,results_path) 
    
end





