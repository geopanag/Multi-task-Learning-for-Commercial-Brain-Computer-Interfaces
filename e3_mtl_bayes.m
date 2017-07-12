%%
%   Run Hierarchichal Bayesian Multi task Learning. (code based on
%   http://brain-computer-interfaces.net/, adapted to work with cell arrays instead of 3d)
%       1. Train the algorithm on the train data to get initial distribution of all subjects
%       2. For each new subject, train on stratified 10% of the whole
%          recordings, using the distribution from step 1
%       3. Use that weight vector to classify the rest 90% and store it in a concatenated vector
%          containing predictions and labels for all tasks
%%

function e3_mtl_bayes(x_train,y_train, x_test,y_test,results_path) 

    gamma = 0.5;
    train_task_num = length(x_train);
    
    %% initialize priors
    dim = size(x_train{1},2);
    mu = zeros(1,dim);
    Sigma = eye(dim)/dim; 

    W = zeros(train_task_num,dim);
    
    %% learn mu, Sigma
    for p = 1:100 % steps on joint learning between mu,Sigma,W and alpha  
        %%learn W

        for t=1:train_task_num
            x = x_train{t}; 
            y = y_train{t}';
            Ax = Sigma*x';
            Coff = (Ax*x+gamma*eye(size(Sigma,1)));
            W(t,:) = inv(Coff)*(Ax * y' + (gamma*mu)');
        end
        
        %%update mean(mu) and covariance(Sigma)
        mu = mean(W(:,:));
        V = W(:,:)'*W(:,:);
        Sigma = V/trace(V)+gamma*eye(dim)/dim;
    end

    
    %% Train in a stratified 10% sample of each subject 
    test_task_num = length(x_test);
    W = zeros(test_task_num,dim);
    
    for t=1:test_task_num
            class1 = find(y_test{t}==1);
            class2 = find(y_test{t}==0);
            train_idx = [randsample(class1,floor(10*length(class1)/100));
                        randsample(class2,floor(10*length(class2)/100))];
            
            x = x_test{t}(train_idx,:);
            y = y_test{t}(train_idx,:)';
            
            test_idx = setdiff((1:length(x_test{t})),train_idx);
            
            x_test{t} = x_test{t}(test_idx,:);
            y_test{t} = y_test{t}(test_idx,:);
            
            Ax = Sigma*x';
            Coff = (Ax*x+gamma*eye(size(Sigma,1)));
            W(t,:) = inv(Coff)*(Ax * y' + (gamma*mu)');
    end
       
    y_pred=[];
    labels = [];
    for t=1:test_task_num
        y_pred = [y_pred; (sign(W(t,:)*x_test{t}'))'];
        labels = [labels ; y_test{t}];
    end
    
    csvwrite(results_path,[labels y_pred]);
    
end   
