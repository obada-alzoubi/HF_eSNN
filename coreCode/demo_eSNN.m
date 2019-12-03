% The Demo file for eSNN 
% eSNN parameters
clc;clear;
Param.m=0.9895;
Param.c=0.999;
Param.s=0.999;
Param.I_min=0;
Param.I_max=1;
Param.nbfields=20;
Param.Beta=1.2;
% 0.9895 0.8092 0.5721
load fisheriris
irislas=ones(150,1);
irislas(51:100)=irislas(51:100)*2;
irislas(101:150)=irislas(101:150)*3;
Data=normalize(meas(:,1:2));
Data=[Data irislas];
%Data=dlmread('spiral.data');
%Data=Data(1:400,[1,2,3,4,5,6,21]);
% data is m*n where the last column is the labels 
% Use 5 folds corsvalidation 
%indices = crossvalind('Kfold',length(Data),5);
%cp = classperf(data);
indices = randi([1,5],size(Data,1),1);
for i = 1:5
    test = (indices == i); train = ~test;
    trainData=Data(train,:);
    testData=Data(test,:);
    repos =train_eSNN(trainData,Param);
    [Accuracy,predicted_labels]=test_eSNN( repos,testData,Param );
    s=sprintf('Accuracy for fold %i : %0.2f%% ',i, 100*Accuracy);
    disp(s);
    fields = fieldnames(repos);
    for j=2:numel(fields)
        s=sprintf('Number of neurons in %s : %d',fields{j},size(repos.(fields{j}).w,1));
        disp(s);
    end
    % Print Confusion Matrix 
    [ldaResubCM,grpOrder] = confusionmat(Data(test,end),predicted_labels);
    ldaResubCM
    

end
