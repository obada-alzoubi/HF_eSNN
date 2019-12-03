function [ spikes ] = rcf( v, Param ,mu ,sigma )
% Convert Samples into spikes 
s=Param.s;
m=Param.m;
c=Param.c;
nb_fields=Param.nbfields;% number of the recptive fields 
I_min=Param.I_min;% The minimum range of the data
I_max=Param.I_max; % The maximun range of the data
Beta=Param.Beta; % parameter of the recptive fields 
sigma=(1/Beta)*((I_max-I_min)/(nb_fields-2));

spikes=[];
for j=1:nb_fields
    % iterate over each receptive field
    %recf=[recf normpdf(v,mu(j),sigma)];
    f=(1/(sqrt(2*(pi))*sigma))*exp((-0.5)*((v-mu(j)) /sigma)^2);
    spikes=[spikes f];
end

end

