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
nL =5; % number of parallel levels
% Temp file to store progress in parfor 
tmpName = tempname; 
[~, fName]= fileparts(tmpName);
%%
addpath('matlab')
addpath('data')
addpath('coreCode')
%% Read Data
dataLocTr = sprintf('data/%s.tr',dat);
dataLocTs = sprintf('data/%s.ts',dat);
nWorkers = nWorkersScript;
tempnWorkers = nWorkers;
parWorkers = parWorkersScript;
testBatchSize = testBatchSizeScript;
trainBatchSizeRatio = trainBatchSizeRatioScript; 
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

%% Parallel Cluster Configuration
tic 
fprintf('Number of workers are %d .....\n',parWorkers)
fprintf('Starting alg. %d .....\n',parWorkers)
batchSize = length (dataTr)/ nWorkers;
fprintf('BatchSize  is %d .....\n',floor(batchSize))
fprintf('Mini Batch Ratio  is %f .....\n',trainBatchSizeRatio)

if  trainBatchSizeRatio > 0 
    sizeBatchedTrain = floor(batchSize*trainBatchSizeRatio);
else
    sizeBatchedTrain = batchSize;
end
correctLastBatch =0;
if mod(batchSize ,2)~=0
     correctLastBatch =1;
end 
% Clean some unwatned data to free memory 
clear  dataTs labelsTs labelsTr data
 %% Parallel implementation
batchFilename = sprintf('data/batch%s%s.mat', fOutput, num2str(trainBatchSizeRatio));
save(batchFilename, 'dataTr', '-v7.3')
clear dataTr
train_Access = matfile(batchFilename);
repos = cell(nWorkers,1);
fprintf('Phase One ... Starting \n')
parfor_progress2(nWorkers, fName); 
parfor p=1:nWorkers
    start = floor((p-1)*(batchSize) +1);
    last =  floor(p*batchSize) ;  
    subsubInd = start:last;
    subsubInd = subsubInd(1: sizeBatchedTrain);
    trainData = train_Access.dataTr(subsubInd, :);
    repos{p,1} =train_eSNN(trainData, Param);
    % Upate progress line     
    parfor_progress2(-1, fName);

end
parfor_progress2(0, fName);
toc
t1 =toc;  
fprintf('Finsihing level one .....\n')
for iL =1: nL 
    if nWorkers >=1
         %% Randomize the reposotories to avoid overfitting
         % We assume that each repos has the same number of classes. 
         if iL==1
            classes = fieldnames (repos{1,1});
         else
            classes = fieldnames (repos{1});
         end

         classes = classes (2:end,1);
         mainRepos = cell(nWorkers,1);
         for j =1 :numel (classes)
             w_all = [];
             theta_all =[];
             psp_all = [];
             nbmerges_all = [];
             label_all = []; 
             data_all = [];
             for i=1:nWorkers
                 % Loop over each classes from each repos.
                 w_all = [w_all ;  repos{i,1}.(classes{j,1}).w];
                 theta_all = [ theta_all ; repos{i,1}.(classes{j,1}).theta];
                 psp_all = [psp_all ; repos{i,1}.(classes{j,1}).psp] ;
                 nbmerges_all = [nbmerges_all ; repos{i,1}.(classes{j,1}).nbmerges];
                 label_all = [label_all ;  repos{i,1}.(classes{j,1}).label];
                 %data_all =[ data_all;  repos{i,1}.(classes{j,1}).data];   
                 data_all =[];              
                 
             end
             n =  size (w_all,1);% the number of total wights from all batches
             p = randperm(n);% randomize data to prevent overfitting
             w_all = w_all(p,:);
             theta_all = theta_all(p,:);
             psp_all = [];
             label_all = label_all (1,:);
             data_all = [];
             nbmerges_all = nbmerges_all(p,:);
             % Must correct here for the number of neurons, we don't want to
             % mess with neurons.
             batchSize = floor(n / nWorkers);
             parfor k =1 : nWorkers
                 % DataBatches 
                 start = (k-1)*(batchSize) +1;
                 last =  k*batchSize ; 
                 repos{k,1}.(classes{j,1}).w = w_all(start:last, :);
                 repos{k,1}.(classes{j,1}).theta = theta_all(start:last,:);
                 repos{k,1}.(classes{j,1}).psp = psp_all;
                 repos{k,1}.(classes{j,1}).label = label_all;
                 repos{k,1}.(classes{j,1}).data = [];        
                 repos{k,1}.(classes{j,1}).nbmerges = nbmerges_all(start:last, :);
                 repos{k,1}.uniquesTrainLabels = repos{k,1}.uniquesTrainLabels;
                 repos{k,1}  = fineMerging( repos{k,1}, Param  );

             end

         end
         toc
         nWorkers = nWorkers -1;
         fprintf('Finsihing level %d .....\n', iL)

    end
end
toc
t2 = toc;
%% If the number of workers is larger than the number levels 
fprintf('Number of workers before testing is %d \n', nWorkers)
if  length(repos)>1
         %% Randomize the reposotories to avoid overfitting
         % We assume that each repos has the same number of classes. 
         if iL==1
            classes = fieldnames (repos{1,1});
         else
            classes = fieldnames (repos{1});
         end

         classes = classes (2:end,1);
         mainRepos = [];
         for j =1 :numel (classes)
             w_all = [];
             theta_all =[];
             psp_all = [];
             nbmerges_all = [];
             label_all = []; 
             data_all = [];
             for i=1:length(repos)
                 % Loop over each classes from each repos.
                 w_all = [w_all ;  repos{i,1}.(classes{j,1}).w];
                 theta_all = [ theta_all ; repos{i,1}.(classes{j,1}).theta];
                 psp_all = [psp_all ; repos{i,1}.(classes{j,1}).psp] ;
                 nbmerges_all = [nbmerges_all ; repos{i,1}.(classes{j,1}).nbmerges];
                 label_all = [label_all ;  repos{i,1}.(classes{j,1}).label];
                 %data_all =[ data_all;  repos{i,1}.(classes{j,1}).data];   
                 data_all =[];              
                 
             end
              mainRepos.(classes{j,1}).w = w_all;
              mainRepos.(classes{j,1}).theta = theta_all;
              mainRepos.(classes{j,1}).psp = psp_all;
              mainRepos.(classes{j,1}).label = label_all(1);
              mainRepos.(classes{j,1}).data = [];        
              mainRepos.(classes{j,1}).nbmerges = nbmerges_all;
              mainRepos.uniquesTrainLabels = [];
         end
else
    mainRepos = repos;
    clear repos;
end
%% Test data 
fileName = sprintf('data/mainReposT2_%s%s.mat',fOutput, num2str(trainBatchSizeRatio));
save(fileName, 'mainRepos', '-v7.3')
% load test data
fprintf('Start testing phase \n')
test_Access = matfile(testFilename);
%batchSize = floor( size(test_Access.dataTs,1)/nWorkers);
%batchSize =300;
if testBatchSize >0
    batchSize = testBatchSize;
else
    batchSize =floor( size(test_Access.dataTs,1)/tempnWorkers);
end
allAcc = zeros(tempnWorkers, 1);
parfor_progress2(tempnWorkers, fName);
for p=1:tempnWorkers
    start = floor((p-1)*(batchSize) +1);
    last =  floor(p*batchSize) ; 
    testData = test_Access.dataTs(start: last, :);
    [allAcc(p), ~]=test_eSNN( mainRepos,testData,Param );
    parfor_progress2(-1, fName);
end
 parfor_progress2(0, fName);
 % Overall all accuracy 
Accuracy = sum(allAcc(:))/tempnWorkers;
%  Print Statisitcs about the classes
try
    cl = fieldnames(mainRepos);
catch
try 
    mainRepos = mainRepos{1};  
    cl = fieldnames(mainRepos);
catch
    mainRepos = mainRepos{1,1};  
    cl = fieldnames(mainRepos);   
end
end    
nNeurons =0;
c= 1;
for j=1 : numel(cl)
  if ~isempty (strfind( cl{j}, 'Class'))
      n = size(mainRepos.(cl{j}).w, 1);
      fprintf ('num neurons for %s is: %d \n' ,cl{j}, n)
      nNeurons = nNeurons +n ;
      c = c +1;
  end
end 
%
S =whos('mainRepos');
comp = (1- (nNeurons/nTraining));
fprintf ('Comp. ratio is %0.2f \n', comp)
fprintf('Time: %d - accuracy: %0.4f \n',t2,Accuracy)
res = [ id t1 t2 parWorkers tempnWorkers Accuracy comp trainBatchSizeRatio sizeBatchedTrain testBatchSize S.bytes];
dlmwrite(fOutput, res,'-append')
fprintf ('---------------------- Done--------------------- \n')
