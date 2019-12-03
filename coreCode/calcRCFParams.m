function [ sigma, mu, rcf_mu ] = calcRCFParams( Param)
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
% make the spikes as delays
rcf_mu = rcf4(mu(1), Param , mu ,sigma, 1);
