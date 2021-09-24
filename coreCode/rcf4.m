function [ spikes ] = rcf4(v, Param ,mu ,sigma, f_ind )
% Convert Samples into spikes 
s=Param.s;
m=Param.m;
c=Param.c;
pdf_option  = Param.pdf_option; 
nb_fields=Param.nbfields;% number of the recptive fields 
I_min=Param.I_min;% The minimum range of the data
I_max=Param.I_max; % The maximun range of the data
Beta=Param.Beta; % parameter of the recptive fields 
sigma=(1/Beta)*((I_max-I_min)/(nb_fields-2));
pd_f = Param.pdf_option;

spikes=[];
for j=1:nb_fields
    % iterate over each receptive field
    %recf=[recf normpdf(v,mu(j),sigma)];
    switch pdf_option
        case 'Normal'
            %f=(1/(sqrt(2*(pi))*sigma))*exp((-0.5)*((v-mu(j)) /sigma)^2);
            %spikes=[spikes f];
            f = pdf(pdf_option, v, mu(j), sigma);
            spikes=[spikes f];
        case 'Laplace'
            f=lappdf(v,mu(j),sigma);
            spikes=[spikes f];
        case 'fitted'
            f = pdf(pd_f(f_ind).pd, v);
            spikes=[spikes f];

        otherwise % Matlab built-in  function
            f = pdf(pdf_option, v+1, mu(j)+1, sigma);
            spikes=[spikes f];
            
    end
end