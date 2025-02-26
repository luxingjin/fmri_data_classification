%% shuffle data for FMRI Stacked Autoencoder
%
% initilize
close all;clear all;clc

addpath '../Classifiers'
for datasetnum = 2:2

%% choose dataset
% Todo : loop over 4 datasets
% 
kfold = 10;


% choose dataset
% Todo : return a struct instead of multiple varibles
% build a struct to collect inputSize, trainingset, testset and labels 
dataset = selectDataset( datasetnum );

%% initialize parameter
parameters.numClasses = 2;
parameters.hiddenSizeL1 = 200;    % Layer 1 Hidden Size
parameters.hiddenSizeL2 = 200;    % Layer 2 Hidden Size
parameters.sparsityParam = 0.1;   % desired average activation of the hidden units.
                       % (This was denoted by the Greek alphabet rho, which looks like a lower-case "p",
		               %  in the lecture notes).
parameters.lambda = 3e-3;         % weight decay parameter
parameters.beta = 3;              % weight of sparsity penalty term
parameters.inputSize = dataset.inputSize;


for i = 1:kfold
%% validation
% choose the best lambda  
% randomly partition the dataset to 10 subsets,
% 9 for training, 1 for testing
s_dataset = shuffleFMRIDataset( dataset, kfold);


% Todo : change this part to use validateSAE
% % validateSoftmax2 will further randomly partition the training set
% % to 10 subset, 9 for training , 1 for validating
% % choose the bestlambda by average 10 accuracy
% [bestlambda,valacc]  = validateSoftmax2( lambda_list, inputSize, ...
%     s_trainingset, s_traininglabels, kfold );
% valacc_list(i) = valacc;
% bestlambda_list(i) = bestlambda;

% testing
% why is testing accuracy higher than validation accuracy ?  -_-
%
% [trainacc, testacc, softmaxModel] = softmaxFMRI( bestlambda, range ,inputSize, ...
% s_trainingset, s_traininglabels, ...
% s_testset, s_testlabels);
% trainacc_list(i) = trainacc;
% testacc_list(i) = testacc;
% filename = sprintf('softmaxModel_datasetnum%d_%ditr.mat',datasetnum,i);
% save(filename,'softmaxModel');
[ accuracys, thetas ] = FMRIstackedAEFunction(s_dataset, parameters );
% filename = sprintf('saves/saeweights_datasetnum%d_%ditr',datasetnum,i);
% save(filename,'thetas');
trainacc_list(i,1) = accuracys.trainacc1;
testacc_list(i,1) = accuracys.testacc1;
trainacc_list(i,2) = accuracys.trainacc2;
testacc_list(i,2) = accuracys.testacc2;


end

%% average the k times' test accuracy to reduce the bias 
% valacc = 1/kfold*sum(valacc_list(:));
trainacc1 = 1/kfold*sum(trainacc_list(:,1));
testacc1 = 1/kfold*sum(testacc_list(:,1));
trainacc2 = 1/kfold*sum(trainacc_list(:,2));
testacc2 = 1/kfold*sum(testacc_list(:,2));
accname = sprintf('acc_dataset_%d.mat',datasetnum);
save(accname, 'trainacc_list','testacc_list');

%% plot
% Todo 
figure;
% subplot(2,1,1);
hold all
h1 = plot(1:kfold,trainacc_list(:,1),'-.og','MarkerFaceColor','r');
h2 = plot(1:kfold,testacc_list(:,1),'-.oy','MarkerFaceColor','b');
h3 = plot(1:kfold,trainacc_list(:,2));
h4 = plot(1:kfold,testacc_list(:,2),'Color','k');
h5 = plot(1:kfold,testacc1*ones(kfold,1),'Color','y');
h6 = plot(1:kfold,testacc2*ones(kfold,1),'Color','m');
hold off
labels = {'training accuracy before tuning','test accuracy before tuning',...
    'training accuracy after tuning','test accuracy after tuning',...
    'average test accuracy before tuning', 'average test accuracy after tuning'};
legend([h1,h2,h3,h4,h5,h6],labels);
str = sprintf('training and testing accuracy,datasetnum:%d, %d-fold',datasetnum,kfold);
title(str);
xlabel('the nth time of iteration');
ylabel(' accuracy');
% figname = sprintf('saves/dataset_%d_accuracy',datasetnum);
% savefig(figname);
% 
% subplot(2,1,2);
% % figure;
% semilogy(1:kfold,bestlambda_list,'-.or','MarkerFaceColor','g');
% str = sprintf('best lambda,datasetnum:%d, %d-fold',datasetnum,kfold);
% title(str);
% xlabel('the nth time of iteration');
% ylabel('lambda');



end


