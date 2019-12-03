function [ Accuracy,predicted_labels ] = test_eSNN( repos,testData,Param )
samples=testData(:,1:end-1);
label=testData(:,end);
uniqueLabels=unique(label);
UniqueTrainLabels=repos.uniquesTrainLabels;
[C,~]=setdiff(uniqueLabels,UniqueTrainLabels);% find the lables that are new in test data 
% and not exists on train data.
if ~isempty(C) & C~=0
    for i=1:length(C)
        % Add the Class to the repository 
        str=sprintf('Class%d',C(i));
        repos.str=[];
        repos.str.w=[];
        repos.str.theta=[];
        repos.str.psp=[];
        repos.str.nbmerges=[];
    end
end
% iterate over all labels in the repository
allWieghts=[];
allThetas=[];
allLabels=[];
fields = fieldnames(repos);
for i=1:numel(fields)
    if strcmp(fields{i},'uniquesTrainLabels')~=1 && strcmp(fields{i},'str')~=1
        allWieghts=[allWieghts;repos.(fields{i}).w];
        allThetas=[allThetas;repos.(fields{i}).theta];
        allLabels=[allLabels;repos.(fields{i}).label*ones(size(repos.(fields{i}).w,1),1)];
    end
    
end
N=size(samples,1); % Number of testing smaples
nb_correct = 0;
predicted_labels = zeros(N,1);
% Get RCF Params
[ sigma, mu, rcf_mu ] = calcRCFParams( Param);
%parfor_progress(floor(N/20000)); 
for i=1:N
    l=label(i);
    %Print some progress 
    if mod(i,20000)==0
        fprintf('Testing example %d \n', i);
  %      parfor_progress;
    end
    %spikes=populationEncoding(samples(i,:),Param);
     spikes = populationEncoding2(samples(i,:), Param, sigma, mu, rcf_mu);
    [~, ~, class_label,~] = propagate_fast(spikes,repos,Param,allWieghts,allThetas,allLabels);
    clear spikes
    % Store the predicted class for later usages
    if ~ isempty(class_label)% non of the output neurons emittied a spike 
        predicted_labels(i)=class_label;
    else
        predicted_labels(i)=NaN;
        
    end
    if class_label==l
         nb_correct = nb_correct + 1;
    end

end
%hold off
Accuracy=nb_correct/size(testData,1);
%parfor_progress(0);

end

