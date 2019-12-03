clc;clear;
Param.m=0.9;
Param.c=0.7;
Param.s=0.2;
Param.I_min=-1;
Param.I_max=1;
Param.nbfields=20;
Param.Beta=1.5;
%% Set Random Seed to 1234
rng(1234);
% %% IRIS
%[ totalAccuracy ] = eSNN5folds( Data,Param );

%% Diabetes
 Data=dlmread('..\datasets\pima-indians-diabetes.data');
 Datanorm=normalize(Data(:,[1:8]));
 Data=[Datanorm Data(:,end)];
[ totalAccuracy ] = eSNN5folds( Data,Param );

%% Spiral
Data=dlmread('..\datasets\spiral.data');
Datanorm=normalize(Data(:,1:8));
Data=[Datanorm Data(:,end)];
%[ totalAccuracy ] = eSNN5folds( Data,Param );

%% ionosphere
%   Data=dlmread('..\datasets\ionosphere.data');
  %Datanorm=normalize(Data(:,1:end-1));
  %Data=[Datanorm Data(:,end)];
% [ totalAccuracy ] = eSNN5folds( Data,Param );
% 
% %% liver_disorder
% Data=dlmread('..\datasets\liver_disorder.data');
% Datanorm=normalize(Data(:,1:end-1));
% Data=[Datanorm Data(:,end)];
% [ totalAccuracy ] = eSNN5folds( Data,Param );

