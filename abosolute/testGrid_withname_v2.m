%% Param
clc;
warning('off','all')
fprintf ('---------------------- Start--------------------- \n')
%%
addpath('matlab')
addpath('data')
addpath('coreCode')
% 
rng(1234)
%
Param.m=0.99;
Param.c=0.6;
Param.s=0.20;
Param.I_min=-1;
Param.I_max=1;
Param.nbfields=28;
Param.Beta=1.5;
Param.useVal = 0;% use validation in trainign
Param.eval =1000; % evaluate training ever specefic number
Param.useExp = true;
Param.useThreshold = true;
Param.useClassWideRespose = false; 
Param.max_response_time = 1;
dist = {'euclidean', 'seuclidean', 'cityblock', 'chebychev', 'cosine', ...
    'correlation', 'spearman', 	'hamming', 	'jaccard'};
pdf_function  = {'Normal', 'Laplace', 'Beta', 'Gamma', 'HalfNormal', ...
    'InverseGaussian', 'Logistic', 'Nakagami', 'Rayleigh', 'Rician', ...
    'Stable', 'T', 'Weibull'};
% Configure Searching ranges
Param.search.s_range = [0.00001 0.0001 0.001 0.01 0.05 0.1:0.1:0.9 0.995];
Param.search.c_range = [0.00001 0.0001 0.001 0.01 0.05 0.1:0.1:0.9 0.995];
Param.search.m_range = [0.1];

Param.search.beta_range =[1.05:0.05:2] ;
Param.search.nGRF =[2:1:50];
% Temp file to store progress in parfor 
tmpName = tempname; 
[~, fName]= fileparts(tmpName);
%% Read Data
dataLocTr = sprintf('data/%s.tr',dat);
dataLocTs = sprintf('data/%s.ts',dat);
nWorkers = nWorkersScript;% from script
parWorkers = parWorkersScript; % from script
testBatchSize = testBatchSizeScript;%from script
trainBatchSizeRatio = trainBatchSizeRatioScript; %from script
% Read data
[labelsTr, dataTr]= libsvmread(dataLocTr);
dataTr =full(dataTr);
dataTr = scaledata(dataTr,-1,1);
data = [dataTr labelsTr];
% Randomize data 
n =length(labelsTr);
p = randperm(n);
data = data(p, :);
%%
pdca = [];
for k=1:size(data, 2)-1
    d =data(:, k);
    pdca(k).pd = fitdist(d,'Kernel');
end
Param.pd_f = pdca;

clear dataTr
% Select specific number of samples for grid search 
data = data(1:10000, :);
disp('Grid Search is done part of the data = 10000')

%% Perform grid search 
Param.dist = dist{testBatchSize}; 
 Param.pdf_option= pdf_function{trainBatchSizeRatio};
[ best_param ] = gridSearch2( data, Param );
% Write the results 
output_file = sprintf('bp_orginal_withexp_%s_%s.mat', Param.dist, Param.pdf_option);
save(output_file,'best_param')
fprintf('Finished Searching \n')
