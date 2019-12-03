function [ f_spikes ] = populationEncoding3(sample, Param, sigma, mu, rcf_mu)
numFeas=size(sample,2);% Number of the features in each sample
% make the spikes as delays
rcf_max = rcf_mu(1);
f_spikes = [] ; 
f_spikes = rcf4(sample, Param, mu, sigma, i )/rcf_max;
f_spikes=-1*f_spikes + 1;

end
