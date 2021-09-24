clc;clear;
%% 
%% Add path for some needed codes 
addpath('matlab') 
addpath('data')
addpath('coreCode')
%%
dist = 'euclidean';% distance metric to merge neurons
pdf_f = 'Normal';% Experimetnal .. use Normal for default. Other receptive fields can be used.
s = 0.1;% threshold of merging neurons. High value will merge more neurons and make model more simple
c = 0.8; % satuartion controling variable 
m = 0.9;% m paramter for Thorp's neural model ..in case you are using Thorp's model. if you are using NRO model presented in the paper (See refernces), you don't need m paramter. 
I_min = -1; % lower range of the receptive field 
I_max = +1; % upper range of the receptive field 
nbfields = 32; % number of neurons to reprent each feature
Beta= 1.5; % the width of guassain field 
max_response_time = 0.9;
Param.m=m;
Param.c=c;
Param.s=s;
Param.pdf_option = pdf_f;
Param.pd_f = pdf_f;

Param.dist = dist;
max_response_time = 0.9;
% See Equation 1 in the paper for more infromation about I_min and I_max
Param.I_min=I_min;
Param.I_max=I_max;
% nbfields is M in the paper. The number of neurons to reperesnt each feature 
Param.nbfields=nbfields;
% Beta paramters in equation 2 of the manuscript
Param.Beta=Beta;
Param.useVal = 0;% use validation in trainign ( not used now)
% Experimetnal
Param.eval =1000; % evaluate training ever specefic number ( not used now)
Param.useThreshold = true; % don't worry about  this
Param.useClassWideRespose = true; % don't worry about this

Param.max_response_time = max_response_time; % don't worry about this

%% Set Random Seed to 1234
rng(1234);
% %% IRIS
%[ totalAccuracy ] = eSNN5folds( Data,Param );

%% fisheriris dataset
load fisheriris
irislas=ones(150,1);
irislas(51:100)=irislas(51:100)*2;
irislas(101:150)=irislas(101:150)*3;
Data=normalize(meas(:,1:2));
Data=[Data irislas];

%% ionosphere
indices = randi([1,3],size(Data,1),1);
repos =train_eSNN4(Data(indices~=1, :),Param);
[Accuracy,predicted_labels]=test_eSNN3( repos,Data(indices==1, :),Param );