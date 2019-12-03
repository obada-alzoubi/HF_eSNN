function [repos] = mergeNeuron2( neuron,repos,w,theta,l )


repos.w(neuron,:)=w'+repos.nbmerges(neuron)*repos.w(neuron,:)...
    /(1+repos.nbmerges(neuron));
repos.theta(neuron)=theta+repos.nbmerges(neuron)*repos.theta(neuron)...
    /(1+repos.nbmerges(neuron));
repos.nbmerges(neuron)=1+repos.nbmerges(neuron);

end

