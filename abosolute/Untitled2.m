list_options ={'bp_chebychev_Normal.mat', 'bp_cityblock_Normal.mat', ...
    'bp_correlation_Normal.mat', 'bp_cosine_Normal.mat', 'bp_euclidean_Normal.mat',...
    'bp_hamming_Normal.mat','bp_spearman_Normal.mat'};
fid = fopen('result_distance.csv','w');
fprintf(fid, 'Distance Metric, Best Accuracy, s, c,m , Best Compression, s, c, m, Best Balanced, s, c, m \n');

for i=1:length(list_options)
    
dist_name = strsplit(list_options{i},'_');
dist_name = dist_name{2};
load(list_options{i})
[acc_val, acc_ind] = max(best_param(:, 4));
s_acc = best_param(acc_ind, 1);
c_acc = best_param(acc_ind, 2);
m_acc = best_param(acc_ind, 3);

[comp_val, comp_ind ] = max(best_param(:, 5));
s_comp = best_param(comp_ind, 1);
c_comp = best_param(comp_ind, 2);
m_comp = best_param(comp_ind, 3);

balaced = 0.5*best_param(:, 4) +0.5*best_param(:, 5);
[bal_val, bal_ind ] = max(balaced);
s_bal = best_param(bal_ind, 1);
c_bal = best_param(bal_ind, 2);
m_bal = best_param(bal_ind, 3);

fprintf(fid, '%s, %0.3f, %0.3f, %0.3f, %0.3f, %0.3f, %0.3f, %0.3f, %0.3f, %0.3f, %0.3f, %0.3f, %0.3f \n',...
    dist_name, acc_val, s_acc, c_acc, m_acc, comp_val, s_comp, c_comp,...
    m_comp, bal_val, s_bal, c_bal, m_bal);
end
fclose(fid);