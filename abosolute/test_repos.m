%% Param
warning('off','all')
fprintf ('---------------------- Start--------------------- \n')
clc;
Param.m=0.9;
Param.c=0.7;
Param.s=0.6;
Param.I_min=-1;
Param.I_max=1;
Param.nbfields=20;
Param.Beta=1.5;
rng(1234)
id=1;
% Temp file to store progress in parfor 
tmpName = tempname; 
[~, fName]= fileparts(tmpName);
fName = strcat('coreCode/%s',fName);
%%
t1= 17*60;
t2= 1.132204e+03;
addpath('matlab')
addpath('data')
addpath('coreCode')
%% Read Data
dataLocTr = sprintf('data/%s.tr',dat);
dataLocTs = sprintf('data/%s.ts',dat);
nWorkers = nWorkersScript;
parWorkers = parWorkersScript;
[labelsTr, dataTr]= libsvmread(dataLocTr);
missingTs =0;
% Testing
[labelsTs, dataTs]= libsvmread(dataLocTs);
if isempty(labelsTs)    
    missingTs =1;
end
if missingTs ==0
    dataTs =full(dataTs);
    dataTs = scaleCol(dataTs,-1,1);
    dataTr =full(dataTr);
    dataTr = scaleCol(dataTr,-1,1);
else
    data =full(dataTr);
    %data = data(1:100000,:);
    l = labelsTr;
    data= scaleCol(data,-1,1);
    n =length(labelsTr);
    tr = floor(0.7*n);
    p = randperm(n);
    dataTr = data(p(1:tr), :);
    labelsTr = l(p(1:tr), :);
    labelsTs = l(p(tr:end), :);
    dataTs = data(p(tr:end), :);
	fprintf('No testing data ..held data from training\n')	
end
nTraining = size(dataTr, 1);
fprintf('Data has been loaded \n')
fprintf('Training data size is %d * %d \n', size(dataTr))
fprintf('Testing data size is %d * %d \n', size(dataTs))
% Add label column to the end
labelsTs(labelsTs==-1) =0;
labelsTr(labelsTr==-1) =0;
dataTs = [dataTs labelsTs];
dataTr = [dataTr labelsTr];
p = randperm(size(dataTr, 1));% randomize data to prevent overfitting
dataTr = dataTr(p, :);
fprintf('Data has been loaded \n')
testFilename = sprintf('data/test%s.mat', fOutput);
if ~exist(testFilename)
    save(testFilename, 'dataTs','-v7.3');
    fprintf('Testing data was saved \n')
else
    fprintf('Testing is already there \n')
end 
clear data dataTr labelsTr
%% Start Testing 
% load Final Repos 
fileName = sprintf('data/finalRepos%s.mat',fOutput);
load(fileName);
% Test data 
% load test data
tic 
fprintf('Start testing phase \n')
test_Access = matfile(testFilename);
batchSize =300;
allAcc = zeros(nWorkers, 1);
parfor_progress2(nWorkers, fName);
for p=1:nWorkers
    start = floor((p-1)*(batchSize) +1);
    last =  floor(p*batchSize) ; 
    testData = test_Access.dataTs(start: last, :);
    [allAcc(p), ~]=test_eSNN( finalRepos,testData,Param );
    parfor_progress2(-1, fName);
end
 parfor_progress2(0, fName);
 % Overall all accuracy 
Accuracy = sum(allAcc(:))/nWorkers;
%  Print Statisitcs about the classes 
cl = fieldnames(finalRepos);
nNeurons =0;
c= 1;
for j=1 : numel(cl)
  if ~isempty (strfind( cl{j}, 'Class'))
      n = size(finalRepos.(cl{j}).w, 1);
      fprintf ('num neurons for %s is: %d \n' ,cl{j}, n)
      nNeurons = nNeurons +n ;
      c = c +1;
  end
end 
%
toc
comp = (1- (nNeurons/nTraining));
fprintf ('Comp. ratio is %0.2f \n', comp)
fprintf('Time: %d - accuracy: %0.4f \n',t2,Accuracy)
res = [ id t1 t2 parWorkers nWorkers Accuracy comp];
dlmwrite(fOutput, res,'-append')
fprintf ('---------------------- Done--------------------- \n')
