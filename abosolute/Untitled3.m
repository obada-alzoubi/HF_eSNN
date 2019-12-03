function [ output_args ] = Untitled3( repos, data, Param  )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
nSamples = size(data, 1);
num_repos = length(repos); % Mulit-repos testing.
allPredicted = cell(Param.nWorkers, 1);
allActivations = cell(Param.nWorkers, 1);
parfor p=1 : num_repos
     [allAcc(p), allPredicted(p), allActivations(p)]=...
         test_eSNN4_dist( repos{p}, data,Param );
    parfor_progress2(-1, fName);
    
end 
diag_all_labels = zeros(nSamples, num_repos);
diag_all_activations = zeros(nSamples, num_repos);

for p=1: num_repos
    diag_all_labels(:, p) = allPredicted(p);
    diag_all_activations(: , p) = allActivations(p);
end
[v, ind] = max(diag_all_activations, 2);
labels_pred = diag_all_labels(:, ind);
label=data(:,end);

end

