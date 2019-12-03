%% Param
warning('off','all')
fprintf ('---------------------- Start--------------------- \n')
clc;
Param.m=0.99;
Param.c=0.3;
Param.s=0.8;
Param.I_min=-1;
Param.I_max=1;
Param.nbfields=28;
Param.Beta=1.5;
Param.useVal = 0;% use validation in trainign
Param.eval =1000; % evaluate training ever specefic number
dist = {'euclidean', 'seuclidean', 'cityblock', 'chebychev', 'cosine', ...
    'correlation', 'spearman', 	'hamming', 	'jaccard'};

pdf_function  = {'Normal', 'Laplace', 'Beta', 'Gamma', 'HalfNormal', ...
    'InverseGaussian', 'Logistic', 'Nakagami', 'Rayleigh', 'Rician', ...
    'Stable', 'T', 'Weibull'};
Param.search.s_range = [0.1:0.1:0.9];
Param.search.c_range = [0.1:0.1:0.9];
Param.search.m_range = [0.1:0.1:0.9];
Param.pdf_option=pdf_function{1};
Param.dist = dist{1};
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
%parWorkers = parWorkersScript; % from script
p = gcp('nocreate'); % If no pool, do not create new one.
if isempty(p)
    poolsize = 0;
else
    poolsize = p.NumWorkers;
end
parWorkers = min([parWorkersScript poolsize]);
fprintf('Actual number of parallel workers is %d \n', parWorkers);
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
parfor p=1:nWorkers
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
t1 =toc;  

%% Fine mergin
N_repos = length(repos);
finalRepos.w =[];
finalRepos.theta =[];
finalRepos.psp =[];
finalRepos.nbmerges =[];
finalRepos.label =[];
for p=1:N_repos
    finalRepos.w = [finalRepos.w ;repos{p,1}.w];
    finalRepos.theta=[finalRepos.theta ;repos{p,1}.theta];
    finalRepos.psp=[finalRepos.psp ;repos{p,1}.psp];
    finalRepos.nbmerges=[finalRepos.nbmerges ;repos{p,1}.nbmerges];
    finalRepos.label=[finalRepos.label ;repos{p,1}.label];
end
% fprintf('Execution time of Phase is %0.2f secs:\n', t1/6)
% fprintf('Phase two ... starting \n')
% fileName = sprintf('data/mainRepos_%s%s.mat',s2{2}, num2str(trainBatchSizeRatio));
% save(fileName, 'mainRepos', '-v7.3')
% parfor_progress2(nWorkers, fName);
% parfor p= 1:nWorkers
%     mainRepos{p,1} = fineMerging( mainRepos{p,1}, Param );  
%     parfor_progress2(-1, fName);
% end
% parfor_progress2(0, fName);
% fprintf('Finishing phase2 ....  \n')

%% Updata final repos

clear repos 
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
tic
parfor p=1:8
    start = floor((p-1)*(batchSize) +1);
    last =  floor(p*batchSize) ; 
    testData = test_Access.dataTs(start: last, :);
    [allAcc(p), ~]=test_eSNN2( finalRepos,testData,Param );
    parfor_progress2(-1, fName);
end
 parfor_progress2(0, fName);
 % Overall all accuracy 
Accuracy = sum(allAcc(:))/8;
toc 
%  Print Statisitcs about the classes 
% cl = fieldnames(finalRepos);
% nNeurons =0;
% c= 1;
% for j=1 : numel(cl)
%   if ~isempty (strfind( cl{j}, 'Class'))
%       n = size(finalRepos.(cl{j}).w, 1);
%       fprintf ('num neurons for %s is: %d \n' ,cl{j}, n)
%       nNeurons = nNeurons +n ;
%       c = c +1;
%   end
% end 
% %
% S =whos('finalRepos');
% comp = (1- (nNeurons/nTraining));
% fprintf ('Comp. ratio is %0.2f \n', comp)
% fprintf('Time: %d - accuracy: %0.4f \n',t2,Accuracy)
% res = [ id t1 t2 parWorkers nWorkers Accuracy comp trainBatchSizeRatio sizeBatchedTrain testBatchSize S.bytes];
% dlmwrite(fOutput, res,'-append')
% fprintf ('---------------------- Done--------------------- \n')
