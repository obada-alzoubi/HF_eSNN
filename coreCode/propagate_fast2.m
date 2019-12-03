function [ neuron, spike_time, class_label, active_val ] = propagate_fast2(spikes,repos,Param)
neuron=[];
spike_time=[];
class_label=[];
repos.allpsp=zeros(size(repos.w,1),1);
[~,index]=sort(spikes);
numSipkes = size(spikes,2);
reductio_factor = numSipkes*exp(-1/numSipkes);
for i=1:size(spikes,2)
    %repos.allpsp=repos.allpsp + repos.w(:,index(i))*power(Param.m,i-1);
    if Param.useExp 
        repos.allpsp=repos.allpsp + repos.w(:,index(i))*(exp(-(i-1) /numSipkes)/reductio_factor );
    else
       repos.allpsp=repos.allpsp + repos.w(:,index(i))*power(Param.m,i-1);
    end
    act_min =repos.allpsp-repos.theta;
    active_neurons=find(act_min>= 0);
    if ~isempty(active_neurons) 
        [active_val,ind] = max(repos.allpsp (active_neurons));
        neuron = active_neurons(ind);
        spike_time = spikes(index(i));
        l_mode = mode(repos.label(active_neurons)); 
        %class_label=repos.label(neuron);
        class_label = l_mode;
        return;
        
    end 
end
%If non of neurons fire
unique_label = unique(repos.label);
len_unique_label =length(unique_label);
per_class_psp = nan(len_unique_label, 1);
for iLabel = 1: len_unique_label
    ind_l = find(repos.label==unique_label(iLabel));
    per_class_psp(iLabel) = mean(act_min(ind_l));    
end
 %[active_val,ind]=max(repos.allpsp);
 [active_val, ind] = max(per_class_psp);
 
 %neuron=ind;
 spike_time=0;
 %class_label=repos.label(neuron);
 class_label = unique_label(ind);
return;

end

