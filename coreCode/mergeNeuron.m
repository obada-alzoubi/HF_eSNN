function [repos] = mergeNeuron( neuron,repos,w,theta,l )

str=sprintf('Class%d',l);
repos.(str).w(neuron,:)=w'+repos.(str).nbmerges(neuron)*repos.(str).w(neuron,:)...
    /(1+repos.(str).nbmerges(neuron));
repos.(str).theta(neuron)=theta+repos.(str).nbmerges(neuron)*repos.(str).theta(neuron)...
    /(1+repos.(str).nbmerges(neuron));
repos.(str).nbmerges(neuron)=1+repos.(str).nbmerges(neuron);

end

