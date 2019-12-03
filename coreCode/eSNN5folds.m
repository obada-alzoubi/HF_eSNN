function [ totalAccuracy ] = eSNN5folds( Data,Param )
%indices = crossvalind('Kfold',length(Data),5);
indices = randi([1,5],size(Data,1),1);
%%cp = classperf(data);
totalAccuracy=0;
sum =0;
for i=1:5
    test = (indices == i); train = ~test;
    trainData=Data(train,:);
    testData=Data(test,:);
    repos =train_eSNN(trainData,Param);
    [Accuracy,predicted_labels]=test_eSNN( repos,testData,Param );
%     s=sprintf('Accuracy for fold %i : %0.2f%% ',i, 100*Accuracy);
%     disp(s);
     fields = fieldnames(repos);
 
     for j=2:numel(fields)
         %s=sprintf('Number of neurons in %s : %d',fields{j},size(repos.(fields{j}).w,1));
         %disp(s);
         sum = sum + size(repos.(fields{j}).w,1) ; 
     end
    % Print Confusion Matrix 
    %[ldaResubCM,grpOrder] = confusionmat(Data(551:768,end),predicted_labels);
    %ldaResubCM
    totalAccuracy=Accuracy+totalAccuracy;

end
totalAccuracy= 100*totalAccuracy/5;
avgNeuronsPerRun = sum /(5);
s=sprintf('overall Accuracy  %0.2f%% ', totalAccuracy);
disp(s);
s=sprintf('Avg. Number of Neurons Per Run  %0.2f ', avgNeuronsPerRun);
disp(s);


end

