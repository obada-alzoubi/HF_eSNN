function [ spikes ] = populationEncoding(sample, Param)
s=Param.s;
m=Param.m;
c=Param.c;
nb_fields=Param.nbfields;% number of the recptive fields 
I_min=Param.I_min;% The minimum range of the data
I_max=Param.I_max; % The maximun range of the data
Beta=Param.Beta; % parameter of the recptive fields 
sigma=(1/Beta)*((I_max-I_min)/(nb_fields-2));
% Calculate the means of the receptive fields 
mu=zeros(nb_fields,1);
for i=1:nb_fields
    %iterate over each receptive field
    mu(i)=I_min+((2*i-3)/2)*((I_max-I_min)/(nb_fields-2));
end
%mu=I_min+((2*i+3)/2)*((I_max-I_min)/nb_fields-2);
numFeas=size(sample,2);% Number of the features in each sample
% make the spikes as delays
rcf_mu = rcf (mu(1), Param , mu ,sigma );
rcf_max = rcf_mu(1);
spikes = [] ; 
for i=1:numFeas
    f_spikes = rcf (sample(i), Param, mu, sigma )/rcf_max;
    spikes = [ spikes f_spikes];
end
spikes=-1*spikes + 1;




end

