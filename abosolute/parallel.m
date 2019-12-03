%% Param
warning('off','all')
fprintf ('---------------------- Start--------------------- \n')
clc;
Param.m=0.95;
Param.c=0.85;
Param.s=0.25;
Param.I_min=-1;
Param.I_max=1;
Param.nbfields=30;
Param.Beta=1.5;
Param.useVal = 0;% use validation in trainign
Param.eval =1000; % evaluate training ever specefic number
dist = {'euclidean', 'seuclidean', 'cityblock', 'chebychev', 'cosine', ...
    'correlation', 'spearman', 	'hamming', 	'jaccard'};
Param.dist = dist{1};	
Param.search.s_range = [0.1:0.1:0.9];
Param.search.c_range = [0.1:0.1:0.9];
Param.search.m_range = [0.1:0.1:0.9];
Param.dist = dist{1};
Param.pdf_option='Normal';

rng(1234)
id=1;
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
nWorkers = nWorkersScript;% from script
parWorkers = parWorkersScript; % from script
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
s1= strsplit(fOutput,'.');% Remove extra part of file name from bash input
s2 = strsplit(s1{1},'''');
if length(s2)==1
    s2{2} = s2{1};
end
testFilename = sprintf('data/test%s%s.mat', s2{2},num2str(trainBatchSizeRatio));
%% Get some data for validation
nTesting = size(labelsTs, 1);
tVal = floor(0.1*nTesting);
if tVal < Param.eval
    Param.eval = tVal;
    fprintf('Param.eval is  now %d \n', Param.eval)
end
dataVal = dataTs(1:tVal, :);
dataTs = dataTs(tVal:end, :);
%% Store Testing data 
if ~exist(testFilename)
    save(testFilename, 'dataTs','-v7.3');
    fprintf('Testing data was saved \n')
else
    fprintf('Testing is already there \n')
end
%% Store Validation data
valFilename = sprintf('data/val%s%s.mat', s2{2},num2str(trainBatchSizeRatio));
if ~exist(valFilename)
    save(valFilename, 'dataVal','-v7.3');
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

correctLastBatch =0;
if mod(batchSize ,2)~=0
     correctLastBatch =1;
end
if  trainBatchSizeRatio > 0 
    sizeBatchedTrain = floor(batchSize*trainBatchSizeRatio);
else
    sizeBatchedTrain = batchSize;
end
% Clean some unwatned data to free memory 
clear  dataTs labelsTs labelsTr data
 %% Parallel implementation
batchFilename = sprintf('data/batch%s%s.mat', s2{2},num2str(trainBatchSizeRatio));
save(batchFilename, 'dataTr', '-v7.3')
clear dataTr
train_Access = matfile(batchFilename);
repos = cell(nWorkers, 1);
trAccPhase1 = cell(nWorkers, 1);
valAccPhase1 = cell(nWorkers, 1);
trAccPhase2 = zeros(nWorkers, 1);
valAccPhase2 = zeros(nWorkers, 1);
fprintf('Phase One ... Starting \n')
parfor_progress2(nWorkers, fName);
Param.val = dataVal;
for p=1:nWorkers
    start = floor((p-1)*(batchSize) +1);
    last =  floor(p*batchSize) ; 
    subsubInd = start:last;
    subsubInd = subsubInd(1: sizeBatchedTrain);
    trainData = train_Access.dataTr(subsubInd, :);
    [repos{p,1}, trAccPhase1{p}, valAccPhase1{p}] =train_eSNN3(trainData, Param);
    % Upate progress line     
    parfor_progress2(-1, fName);

end
parfor_progress2(0, fName); 
fprintf('Phase one is done \n')
fileName = sprintf('data/Acc_%s%s.mat',s2{2}, num2str(trainBatchSizeRatio));
save(fileName, 'trAccPhase1', 'valAccPhase1', '-v7.3')
clear DataBatches

 %% Randomize the reposotories to avoid overfitting
 classes = fieldnames (repos{1,1});
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
	 try
         	w_all = [w_all ;  repos{i,1}.(classes{j,1}).w];
         	theta_all = [ theta_all ; repos{i,1}.(classes{j,1}).theta];
         	psp_all = [psp_all ; repos{i,1}.(classes{j,1}).psp] ;
         	nbmerges_all = [nbmerges_all ; repos{i,1}.(classes{j,1}).nbmerges];
         	label_all = [label_all ;  repos{i,1}.(classes{j,1}).label];
         	data_all =[];
	 catch
	 end
     end
         n =  size (w_all,1);% the number of total wights from all batches
         p = randperm(n);% randomize data to prevent overfitting
         w_all = w_all(p,:);
         theta_all = theta_all(p,:);
         %psp_all = psp_all;
         label_all = label_all (1,:);
         %data_all = data_all(p,:);
         nbmerges_all = nbmerges_all(p,:);
         % Must correct here for the number of neurons, we don't want to
         % mess with neurons.
         batchSize = floor(n / nWorkers);
         for k =1 : nWorkers
             % DataBatches 
             start = (k-1)*(batchSize) +1;
             last =  k*batchSize ; 
    %          if correctLastBatch == 1 && k==nWorkers
    %             last = last +1;
    %          end
             mainRepos{k,1}.(classes{j,1}).w = w_all(start:last, :);
             mainRepos{k,1}.(classes{j,1}).theta = theta_all(start:last,:);
             mainRepos{k,1}.(classes{j,1}).psp = psp_all;
             mainRepos{k,1}.(classes{j,1}).label = label_all;
             mainRepos{k,1}.(classes{j,1}).data = [];        
             mainRepos{k,1}.(classes{j,1}).nbmerges = nbmerges_all(start:last, :);
             mainRepos{k,1}.uniquesTrainLabels = repos{k,1}.uniquesTrainLabels;
         
         
         end
     
 end
t1 =toc;  
clear repos w_all theta_all psp_all data_all label_all
%% Fine merging 
fprintf('Execution time of Phase is %0.2f secs:\n', t1/6)
fprintf('Phase two ... starting \n')
fileName = sprintf('data/mainRepos_%s%s.mat',s2{2}, num2str(trainBatchSizeRatio));
save(fileName, 'mainRepos', '-v7.3')
parfor_progress2(nWorkers, fName);
parfor p= 1:nWorkers
    mainRepos{p,1} = fineMerging( mainRepos{p,1}, Param );  
    parfor_progress2(-1, fName);
end
parfor_progress2(0, fName);
fprintf('Finishing phase2 ....  \n')

%% Updata final repos
% First get all available classes in the data
classes= {};
c =1;
for i = 1:nWorkers
      cl = fieldnames(mainRepos{i,1});
      for j=1 : numel(cl)
          if ~isempty (strfind( cl{j}, 'Class'))&& ~any(strcmp(classes,  cl{j}))
              classes{c} =  cl{j};
              c = c +1;
          end
      end    
end

finalRepos= [];
finalRepos.uniquesTrainLabels =[];
for j = 1:numel(classes)
     w_all = [];
     theta_all =[];
     psp_all = [];
     nbmerges_all = [];
     label_all = []; 
     data_all = [];
    for i = 1 : nWorkers
         % Loop over each class from each repos.
	 try
         	w_all = [w_all ;  mainRepos{i,1}.(classes{j}).w];
         	theta_all = [ theta_all ; mainRepos{i,1}.(classes{j}).theta];
         	psp_all = [psp_all ; mainRepos{i,1}.(classes{j}).psp] ;
         	nbmerges_all = [nbmerges_all ; mainRepos{i,1}.(classes{j}).nbmerges];
         	label_all = [label_all ;  mainRepos{i,1}.(classes{j}).label];
         	data_all =[];
	 catch
	 end
      
    end
    finalRepos.(classes{j}).w = w_all;
    finalRepos.(classes{j}).theta = theta_all;
    finalRepos.(classes{j}).psp = psp_all;
    finalRepos.(classes{j}).nbmerges = nbmerges_all;
    finalRepos.(classes{j}).label = unique(label_all);
    finalRepos.(classes{j}).data = [];
    finalRepos.uniquesTrainLabels = [finalRepos.uniquesTrainLabels unique(label_all)];
end
finalRepos.uniquesTrainLabels = unique(finalRepos.uniquesTrainLabels);
t2 = toc;
fprintf('Time before testing: %d \n',t2)
fileName = sprintf('data/finalRepos%s%s.mat',s2{2},num2str(trainBatchSizeRatio));
save(fileName, 'finalRepos','-v7.3')
clear mainRepos w_all psp_all theta_all nbmerges_all

%% Test data 
% load test data
fprintf('Start testing phase \n')
test_Access = matfile(testFilename);
if testBatchSize >0
    batchSize = testBatchSize;
else
    batchSize =floor( size(test_Access.dataTs,1)/nWorkers);
end
allAcc = zeros(nWorkers, 1);
parfor_progress2(nWorkers, fName);
for p=1
    start = floor((p-1)*(batchSize) +1);
    last =  floor(p*batchSize) ; 
    testData = test_Access.dataTs(start: last, :);
    [allAcc(p), ~]=test_eSNN( finalRepos,testData,Param );
    parfor_progress2(-1, fName);
end
 parfor_progress2(0, fName);
 % Overall all accuracy 
Accuracy = sum(allAcc(:))/1;
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
S =whos('finalRepos');
comp = (1- (nNeurons/nTraining));
fprintf ('Comp. ratio is %0.2f \n', comp)
fprintf('Time: %d - accuracy: %0.4f \n',t2,Accuracy)
res = [ id t1 t2 parWorkers nWorkers Accuracy comp trainBatchSizeRatio sizeBatchedTrain testBatchSize S.bytes];
dlmwrite(fOutput, res,'-append')
fprintf ('---------------------- Done--------------------- \n')
