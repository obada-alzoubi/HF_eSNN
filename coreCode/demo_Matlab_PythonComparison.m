clc;clear;
disp('Version 1');
Param.m=0.9;
Param.c=0.6;
Param.s=0.9;
Param.I_min=-1;
Param.I_max=1;
Param.nbfields=20;
Param.Beta=1.5;
%% Seeding 
rng(1234);
%%
datasets = {'spiral' , 'diabetes' , 'iris', 'ionosphere','liverDisorder'};
N = length (datasets);
Acc =0 ;
sum = 0 ;
results = cell(N,2);
for d=1 :N
    datasetName = datasets{d};
    tic 
    for i=1 :5
        [ trainData , testData] = getTTdata( datasetName ,i, ' ');
        % data filtering for specific rows or coloumns if there is.
        if strcmp ( datasetName ,'spiral')
            trainData = trainData(:,[1:5 end]);
            testData =testData(:,[1:5 end]);
        end
        repos =train_eSNN(trainData, Param);
        [Accuracy,predicted_labels]=test_eSNN( repos, testData, Param );
        Acc = Acc + Accuracy;
        fields = fieldnames(repos);

        for j=2:numel(fields)
             sum = sum + size(repos.(fields{j}).w,1) ; 
        end
    end
    toc 
    results{d,1} = Acc*100/5;
    results{d,2} = sum/5;
    Acc = 0;
    sum = 0;

    
end
%100*Acc/5
