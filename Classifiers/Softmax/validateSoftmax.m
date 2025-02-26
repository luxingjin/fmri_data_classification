function  [bestlambda,valacc]  = validateSoftmax2( lambda_list, dataset, kfold )
% validation for softmax
%
% update by 5th Mar,2015: delete the range list
% make it a function


training_data = dataset.trainingset;
training_labels = dataset.traininglabels;

% model selection by validating
% lambda_list = [1,1e-2,1e-3,1e-4,1e-5,1e-6];
range = 0.005;
n_lambda = size(lambda_list,2);
arg_list = zeros(n_lambda,1);
trainacc_list = zeros(n_lambda,1);
valacc_list = zeros(n_lambda,1);
numSample = size(training_data,2);
% kfold = 10;


trainacc_k = zeros(kfold,1);
valacc_k = zeros(kfold,1);
for i = 1:n_lambda
    for k = 1:kfold
        indices = crossvalind('Kfold',numSample,kfold);
        val_set_index = (indices == 1);
        train_set_index = ~val_set_index;
        lambda = lambda_list(i);
        v_dataset.inputSize = dataset.inputSize;
        v_dataset.trainingset = training_data(:,train_set_index);
        v_dataset.traininglabels = training_labels(train_set_index,:);
        v_dataset.testset = training_data(:,val_set_index);
        v_dataset.testlabels = training_labels(val_set_index,:);
        [trainacc, valacc] = softmaxFMRI( lambda, range ,dataset);
        trainacc_k(k) = trainacc;
        valacc_k(k) = valacc;
    end
    trainacc_list(i,1) = 1/kfold*sum(trainacc_k(:));
    valacc_list(i,1) = 1/kfold*sum(valacc_k(:));
end

[bestacc, bestind ] = max(valacc_list(:));
[besti, bestj] = ind2sub(size(valacc_list),bestind);
bestlambda = lambda_list(besti);
valacc = 1/kfold*sum(valacc_k(:));
% trainacc = 1/kfold/lambda*sum(trainacc_list(:));

% [trainacc, testacc] = softmaxFMRI( bestlambda, range ,inputSize, ...
%     training_data, training_labels, ...
%     test_data, test_labels);
% fprintf('Train Accuracy by best validation prameter: %0.3f\n', trainacc);
% fprintf('Test Accuracy by best validation prameter: %0.3f\n', testacc);


% %% plot
% figure;
% semilogx(lambda_list,max(valacc_list,[],2)','-.or','MarkerFaceColor','g');
% str = sprintf('validation accuracy with different lambda,datasetnum:%d, %d-fold',datasetnum,kfold);
% title(str);
% xlabel('lambada');
% ylabel('validation accuracy');
end

