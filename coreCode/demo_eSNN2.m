% The Demo file for eSNN 
% eSNN parameters

clc;clear;
disp('Version 1');
Param.m=0.999;
Param.c=0.7;
Param.s=5;
Param.I_min=-1;
Param.I_max=1;
Param.nbfields=20;
Param.Beta=1.5;
sl=sprintf('[%0.2f , %0.2f ]',Param.I_min,Param.I_max);
% 0.9895 0.8092 0.5721
load fisheriris
irislas=ones(150,1);
irislas(51:100)=irislas(51:100)*2;
irislas(101:150)=irislas(101:150)*3;
Data=normalize(meas(:,1:4));
Data=[Data irislas];
%Data=dlmread('..\datasets\pima-indians-diabetes.data');
%Datanorm=normalize(Data(:,1:8));
%Data=[Datanorm Data(:,end)];
%Data=Data(1:400,[1,2,3,4,5,6,721]);
%Data = Data(randperm(size(Data,1)),:);
% data is m*n where the last column is the labels 
% Use 5 folds corsvalidation 
indices = crossvalind('Kfold',length(Data),5);
%%cp = classperf(data);
totalAccuracy=0;
for i=1:5
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
    %[ldaResubCM,grpOrder] = confusionmat(Data(551:768,end),predicted_labels);
    %ldaResubCM
    totalAccuracy=Accuracy+totalAccuracy;
end
s=sprintf('overall Accuracy  %0.2f%% ', 100*totalAccuracy/5);
disp(s);


