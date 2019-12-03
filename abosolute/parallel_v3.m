%% scritp config
fromScript = 1;
dat ='aloi';
fOutput ='aloi.csv';
if fromScript
 dist = dist_sr;
 pdf_f = pdf_f_sc;
 s = s_sc;
 c = c_sc;
 m = m_sc;
end
addpath('matlab')
addpath('data')
addpath('coreCode')
tmpName = tempname; % progress file
[~, fName]= fileparts(tmpName);
%% Read Data %dat%
dataLocTr = sprintf('data/%s.tr',dat);
dataLocTs = sprintf('data/%s.ts',dat);
[labelsTr, dataTr]= libsvmread(dataLocTr);
[labelsTs, dataTs]= libsvmread(dataLocTs);
if ~isempty(labelsTs)   
    dataTs =full(dataTs);
    dataTs = scaleCol(dataTs,-1,1);
    dataTr =full(dataTr);
    dataTr = scaleCol(dataTr,-1,1);
else
    data =full(dataTr);
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
dataTr = [dataTr labelsTr];
dataTs = [dataTs labelsTs];
fprintf('Data has been loaded \n')
fprintf('Training data size is %d * %d \n', size(dataTr))
fprintf('Testing data size is %d * %d \n', size(dataTs))
nTraining = size(dataTr, 1);
nTesting = size(dataTs, 1);
%% In case we used fitted distribution 
pdca = [];
for k=1:size(dataTr, 2)-1
    d =dataTr(:, k);
    pdca(k).pd = fitdist(d,'Kernel');
end
Param.pd_f = pdca;
%% Output Results % fOutput %
s1= strsplit(fOutput,'.');% Remove extra part of file name from bash input
s2 = strsplit(s1{1},'''');
if length(s2)==1
    s2{2} = s2{1};
end
%% mat files configuration 
% Train data
trainMatFilename = sprintf('data/mat_tr_%s.mat', dat);
save(trainMatFilename, 'dataTr', '-v7.3')
train_Access = matfile(trainMatFilename);
clear dataTr

% Test data
testMatFilename = sprintf('data/mat_ts_%s.mat', s2{2});
if ~exist(testMatFilename)
    save(testMatFilename, 'dataTs','-v7.3');
    fprintf('Testing data was saved \n')
else
    fprintf('Testing is already there \n')
end
test_Access = matfile(testMatFilename);
clear dataTs

%% Parallel Pool 
p = gcp; %
if isempty(p)
    poolsize = 0;
else
    poolsize = p.NumWorkers;
end
%% Param
warning('off','all')
fprintf ('---------------------- Start--------------------- \n')
if fromScript
    Param.m=m;
    Param.c=c;
    Param.s=s;
    Param.pdf_option = pdf_f;
    Param.dist = dist;
end
Param.I_min=-1;
Param.I_max=1;
Param.nbfields=28;
Param.Beta=1.5;
Param.useVal = 0;% use validation in trainign
Param.eval =1000; % evaluate training ever specefic number
Param.max_response_time = 0.9; 
Param.nWorkers = poolsize;
Param.Train = train_Access;
Param.Test = test_Access;
Param.useExp = true;
Param.useThreshold = true;
Param.useClassWideRespose = true; 
%% Training
repos = cell(Param.nWorkers, 1);
trAccPhase1 = cell(Param.nWorkers, 1);
valAccPhase1 = cell(Param.nWorkers, 1);
trAccPhase2 = zeros(Param.nWorkers, 1);
valAccPhase2 = zeros(Param.nWorkers, 1);
parfor_progress2(Param.nWorkers, fName);
batchSize = round(nTraining/ Param.nWorkers);
tic
parfor p=1:Param.nWorkers
    start = floor((p-1)*(batchSize) +1);
    last =  floor(p*batchSize) ; 
    subsubInd = start:last;
    %subsubInd = subsubInd(1: sizeBatchedTrain);
    trainData = Param.Train.dataTr(subsubInd, :);
    [repos{p,1}, trAccPhase1{p}, valAccPhase1{p}] = ...
        train_eSNN4(trainData, Param);
    % Upate progress line     
    parfor_progress2(-1, fName);
end
t1=toc;
parfor_progress2(0, fName); 
fprintf('Phase one is done \n')
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
clear repos
%% FINE MERGING  
[ finalRepos ] = fineMerging( finalRepos, Param  );
%% Test data 
% load test data
fprintf('Start testing phase \n')
allAcc = zeros(Param.nWorkers, 1);
parfor_progress2(Param.nWorkers, fName);
batchSize = round(nTesting/ Param.nWorkers);
tic
parfor p=1:Param.nWorkers
    start = floor((p-1)*(batchSize) +1);
    last =  floor(p*batchSize) ; 
    testData = Param.Test.dataTs(start: last, :);
    [allAcc(p), ~]=test_eSNN3( finalRepos,testData,Param );
    parfor_progress2(-1, fName);
end
t2=toc;
 parfor_progress2(0, fName);
 % Overall all accuracy 
Accuracy = 100*sum(allAcc(:))/Param.nWorkers;
%% Results info 
nNeurons = length(finalRepos.theta);
comp = (1- (nNeurons/nTraining));
fprintf ('Comp. ratio is %0.2f \n', comp)
fprintf('Accuracy: %0.4f \n',Accuracy)
res = [ t1 t2 Param.nWorkers Accuracy comp];
fid = fopen(fOutput, 'a+');
fprintf(fid, '%s, %s, %s, %0.3f, %0.3f, %0.3f, %0.3f, %0.3f, %d, %d, %d, %d, %d \n',...
    Param.pdf_option, Param.dist, dat, Accuracy, comp, Param.s, Param.c,...
    Param.m, Param.nWorkers, t1 ,t2, t1+t2, nNeurons);
fclose(fid);
% dlmwrite(fOutput, res,'-append')
