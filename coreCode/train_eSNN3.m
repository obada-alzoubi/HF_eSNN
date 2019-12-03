function [ repos, tempTrainAcc, tempValAcc] = train_eSNN3(trainData,Param)
%train eSNN function Summary of this function goes here
%   Detailed explanation goes here

s=Param.s;
m=Param.m;
c=Param.c; 
label=trainData(:,end);% labels 
uniqueLabels=unique(label);
max_response_time=1-0.1;

for i=1:size(uniqueLabels)
    % create for each class its own entry 
    repos.w=[];
    repos.theta=[];
    repos.psp=[];
    repos.nbmerges=[];
    repos.label=[];
end

%% Computing the weight and thresholds for each sample

[ sigma, mu, rcf_mu ] = calcRCFParams( Param);
N=size(trainData,1);
tempValAcc = [];
tempTrainAcc = [];

for i=1:N
    % iterate over each data sample
    % get data label
    l=label(i);
    % get spikes information
    spikes = populationEncoding2(trainData(i,1:end-1), Param, sigma, mu, rcf_mu);    %compute the wieghts and thresholds  
    [w,theta]=train_smaple(spikes,m,c,max_response_time);
    % Find the simlar neurons 
    neuron=findSimlar2(w,l,s,repos, Param);
    % merge if we foud a close neuron 
    if isempty(neuron)
        % ADD THE NEURON TO THE REPOSITORY
        repos.w=[repos.w; w'];
        repos.theta=[repos.theta;theta];
        repos.nbmerges=[repos.nbmerges;0];
        repos.label= [repos.label; l];
    else
        repos=mergeNeuron2(neuron,repos,w,theta,l);
    end
    % store validation
%     if mod(i, Param.eval ) == 0 && Param.useVal
%         [ valAcc,~ ] = test_eSNN( repos,Param.val, Param );
%         tempValAcc =[tempValAcc; valAcc];
%         [ TainAcc,~ ] = test_eSNN( repos, trainData(i-Param.eval +1: i, :), Param );
%         tempTrainAcc =[tempTrainAcc; TainAcc];
%         fprintf('Batch %d: Train Acc -- %0.2f   Val. Acc -- %0.2f \n', ...
%             i/1000, 100*TainAcc, 100*valAcc)
%     end

end

