function [ repos ] = train_eSNN(trainData,Param)
%train eSNN function Summary of this function goes here
%   Detailed explanation goes here

s=Param.s;
m=Param.m;
c=Param.c;
%nb_fields=Param.nbfields;% number of the recptive fields 
%I_min=Param.I_min;% The minimum range of the data
%I_max=Param.I_max; % The maximun range of the data
%Beta=Param.Beta; % parameter of the recptive fields 
label=trainData(:,end);% labels 
%samples=trainData(:,1:end-1);% smaples
uniqueLabels=unique(label);
repos.uniquesTrainLabels=uniqueLabels;% Add the unique labels from train labels
max_response_time=1-0.1;
for i=1:size(uniqueLabels)
    % create for each class its own entry 
    str=sprintf('Class%d',uniqueLabels(i));
    repos.(str)=[];
    repos.(str).w=[];
    repos.(str).theta=[];
    repos.(str).psp=[];
    repos.(str).nbmerges=[];
    repos.(str).label=[];
    %repos.(str).data=trainData(trainData(:,end)==uniqueLabels(i),:);
    repos.(str).data=[];

end
% %% Order the train Samples 
% orderTrainData=[];
%  fields = fieldnames(repos);
%  for j=2:numel(fields)
%     center=mean(repos.(fields{j}).data(:,1:end-1));
%     N=size(repos.(fields{j}).data(:,1:end-1),1);
%     l_dist=zeros(N,1);
%     for i=1:N
%         l_dist(i)=norm(center-repos.(fields{j}).data(i,1:end-1));
%         %l_dist(i)=mahal(w',repos.(str).w(i,:)); 
%     end
%     [s_l_dist,ind]=sort(l_dist);
%     orderTrainData=[orderTrainData; repos.(fields{j}).data(ind,:)];
% 
%  end
% %% Computing the weight and thresholds for each sample
% trainData=orderTrainData;
%% Computing the weight and thresholds for each sample
[ sigma, mu, rcf_mu ] = calcRCFParams( Param);
N=size(trainData,1);
for i=1:N
    % iterate over each data sample
    % get data label
    l=label(i);
    % get spikes information
    spikes = populationEncoding2(trainData(i,1:end-1), Param, sigma, mu, rcf_mu);    %compute the wieghts and thresholds  
    [w,theta]=train_smaple(spikes,m,c,max_response_time);
    % Find the simlar neurons 
    neuron=findSimlar(w,l,s,repos);
    % merge if we foud a close neuron 
    if isempty(neuron)
        % ADD THE NEURON TO THE REPOSITORY
        str=sprintf('Class%d',l);
        repos.(str).w=[repos.(str).w; w'];
        repos.(str).theta=[repos.(str).theta;theta];
        repos.(str).nbmerges=[repos.(str).nbmerges;0];
        repos.(str).label=l;
    else
        repos=mergeNeuron(neuron,repos,w,theta,l);
%        repos = weightUpdata( neuron,repos,w,theta,c,l );
    end
%     [ repos ] = stdp(spikes,repos,l,Param);

end

