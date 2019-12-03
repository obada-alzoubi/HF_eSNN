clc;clear;
tic
%% Param
%clc;clear;
Param.m=0.9;
Param.c=0.7;
Param.s=0.6;
Param.I_min=-1;
Param.I_max=1;
Param.nbfields=20;
Param.Beta=1.5;
id=1;
addpath('matlab')
%% Read data 
% Training
[labelsTr, dataTr]= libsvmread('cod-rna.tr');
% Testing
[labelsTs, dataTs]= libsvmread('cod-rna.ts');
% From sparse to full 
dataTs =full(dataTs);
dataTs = scaleCol(dataTs,-1,1);
dataTr =full(dataTr);
dataTr = scaleCol(dataTr,-1,1);
% Add label column to the end
labelsTs(labelsTs==-1) =0;
labelsTr(labelsTr==-1) =0;

dataTs = [dataTs labelsTs];
dataTr = [dataTr labelsTr];
%% Train 
fprintf('Training.... \n')
repos =train_eSNN(dataTr, Param); 
t = toc; 
t
%% Test 
fprintf('Testing.... \n')
[ Accuracy,predicted_labels ] = test_eSNN( repos,dataTs,Param );
Accuracy
fprintf('time: %d - accuracy: %0.4f \n',t,Accuracy)
res = [ id t nWorkers Accuracy];
dlmwrite('result.csv', res,'-append')