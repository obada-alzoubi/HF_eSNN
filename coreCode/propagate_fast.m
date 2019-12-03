function [ neuron, spike_time, class_label,active_neurons ] = propagate_fast(spikes,repos,Param,allWeights,allThetas,allLabels)
neuron=[];
spike_time=[];
class_label=[];
repos.allpsp=zeros(size(allWeights,1),1);
[~,index]=sort(spikes);
for i=1:size(spikes,2)
    repos.allpsp=repos.allpsp + allWeights(:,index(i))*power(Param.m,i-1);
    active_neurons=find(repos.allpsp>allThetas);
    if ~isempty(active_neurons)
        [active_val,ind]=max(repos.allpsp (active_neurons));
        neuron=active_neurons(ind);
        spike_time=spikes(index(i));
        class_label=allLabels(neuron);
        if length(unique(allLabels(active_neurons)))> 1
           
        end
        return;
        
    end 
end
%If non of neurons fire
 [active_val,ind]=max(repos.allpsp);
 neuron=ind;
 spike_time=0;
 class_label=allLabels(neuron);
return;

end

