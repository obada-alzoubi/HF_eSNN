function [ Accuracy,  labels_pred] = test_eSNN_enc( repos, data, Param  )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
nSamples = size(data, 1);
num_repos = length(repos); % Mulit-repos testing.
allPredicted = cell(Param.nWorkers, 1);
allActivations = cell(Param.nWorkers, 1);
for p=1 : num_repos
     [allAcc(p), allPredicted{p}, allActivations{p}]=...
         test_eSNN4_dist( repos{p}, data,Param );

    
end 
diag_all_labels = zeros(nSamples, num_repos);
diag_all_activations = zeros(nSamples, num_repos);

for p=1: num_repos
    diag_all_labels(:, p) = allPredicted{p};
    diag_all_activations(: , p) = allActivations{p};
end

labels_pred = nan(nSamples ,1);
nComparison = size(diag_all_labels, 2);
for iSample=1: nSamples
    potential_labels = diag_all_labels(iSample, :);
    
   [m, f, ~] = mode(potential_labels);
   if f > nComparison/2
       labels_pred(iSample)= m;
   else
        uniq_labels = unique(potential_labels);
        n_uniq_labels = length(uniq_labels);
        sum_uniq_labels = zeros(n_uniq_labels, 1);
        for iUniq = 1: n_uniq_labels
            t_ind = find (potential_labels == uniq_labels(iUniq));
            sum_uniq_labels(iUniq) = sum(potential_labels(t_ind));
            
        end
        [~, ind_max] = max(sum_uniq_labels);
        labels_pred(iSample)= uniq_labels(ind_max);
        
   end
       
    
end 
label=data(:,end);
nb_correct = length(find(labels_pred == label));
Accuracy=nb_correct/size(data, 1);
end

