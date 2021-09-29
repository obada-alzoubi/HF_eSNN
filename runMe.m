%% scritp config
dist = 'euclidean';% distance metric to merge neurons
pdf_f = 'Normal';% Experimetnal .. use Normal for default. Other receptive fields can be used.
s = 0.05;% threshold of merging neurons. High value will merge more neurons and make model more simple
c = 0.5; % satuartion controling variable 
m = 0;% m paramter for Thorp's neural model ..in case you are using Thorp's model. if you are using NRO model presented in the paper (See refernces), you don't need m paramter. 
%% Add path for some needed codes 
addpath('matlab') 
addpath('data')
addpath('coreCode')
%% Read Data %dat% 
% Theses data are libsvm format, thus we need libsvmread
dataLocTr = sprintf('data/%s.tr',dat);
dataLocTs = sprintf('data/%s.ts',dat);
% Data is stored in libsvm format .. you can use any other formats though. 
[labelsTr, dataTr]= libsvmread(dataLocTr);
[labelsTs, dataTs]= libsvmread(dataLocTs);
% Divide data into testing and training  
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
% last column is labels 
dataTr = [dataTr labelsTr];
dataTs = [dataTs labelsTs];
fprintf('Data has been loaded \n')
fprintf('Training data size is %d * %d \n', size(dataTr))
fprintf('Testing data size is %d * %d \n', size(dataTs))
nTraining = size(dataTr, 1);
nTesting = size(dataTs, 1);
%% In case we used fitted distribution (experimental)
% don't worry about this as well. I was trying other distributions for GRF
pdca = [];
for k=1:size(dataTr, 2)-1
    d =dataTr(:, k);
    pdca(k).pd = fitdist(d,'Kernel');
end
Param.pd_f = pdca;
%% Output Results % fOutput %
% Don't worry about this. Just for the output file
s1= strsplit(fOutput,'.');% Remove extra part of file name from bash input
s2 = strsplit(s1{1},'''');
if length(s2)==1
    s2{2} = s2{1};
end
%% mat files configuration 
%% Param
warning('off','all')
fprintf ('---------------------- Start--------------------- \n')
Param.m=m;
Param.c=c;
Param.s=s;
Param.pdf_option = pdf_f;
Param.dist = dist;
% See Equation 1 in the paper for more infromation about I_min and I_max
Param.I_min=-1;
Param.I_max=1;
% nbfields is M in the paper. The number of neurons to reperesnt each feature 
Param.nbfields=28;
% Beta paramters in equation 2 of the manuscript
Param.Beta=1.5;
Param.useVal = 0;% use validation in trainign ( not used now)
% Experimetnal
Param.eval =1000; % evaluate training ever specefic number ( not used now)
Param.max_response_time = 0.9; % don't worry about this
Param.useExp = false; %don't worry about this
Param.useThreshold = true; % don't worry about  this
Param.useClassWideRespose = true; % don't worry about this

%% Training
% Here you need to divide the data according to different classes .. to test evolving learning 
trainData1 = dataTr(1:5000, :); % first 5000 samples
trainData2 = dataTr(5000:10000, :); % first 5000 samples
% You can train part of the data independently ... felxibility 
[repos1, ~, ~] = train_eSNN4(Data, Param);
[repos2, ~, ~] = train_eSNN4(Data, Param);
% this how you merge different repos.  Let's say repos1 and repos 2 in
% finalRpos
finalRepos.w =[];
finalRepos.theta =[];
finalRepos.psp =[];
finalRepos.nbmerges =[];
finalRepos.label =[];
% Merge two trained Repos.
finalRepos.w = [repos1.w ;repos2.w];
finalRepos.theta=[repos1.theta ;repos2.theta];
finalRepos.psp=[repos1.psp ;repos2.psp];
finalRepos.nbmerges=[repos1.nbmerges ;repos2.nbmerges];
finalRepos.label=[repos1.label ;repos2.label];
%% Finally Testing
testData = dataTs(1:1000, :); %test first 1000 samples
% Test preidiction 
[Acc , pred]=test_eSNN3( repos1,Data,Param );
