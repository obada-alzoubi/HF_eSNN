function [ spikes ] = populationEncoding2(sample, Param, sigma, mu, rcf_mu)
numFeas=size(sample,2);% Number of the features in each sample
% make the spikes as delays
rcf_max = rcf_mu(1);
spikes = [] ; 
for i=1:numFeas
    f_spikes = rcf3(sample(i), Param, mu, sigma, i )/rcf_max;
    spikes = [ spikes f_spikes];
end
spikes=-1*spikes + 1;

end

