 function [ repos ] = fineMerging( repos, Param  )
% Merge similar neurons
s= Param.s;
classes  = fieldnames (repos);
for class = 1:  numel(classes)
    if ~isempty (strfind(classes{class}, 'Class'))
        classData = repos.(classes{class});
        N = size(classData.w, 1); 
        classData.processed = false(1, N);
        goneNeurons = [];
        w_all= classData.w;
        Mdl = KDTreeSearcher(w_all);
        for indNeuron = 1 : N
            % If the sample has not been merged 
            if ~classData.processed(indNeuron)
                classData.processed(indNeuron) = true;
                w_to_merge = classData.w(indNeuron, :);
                theta =  classData.theta(indNeuron);
                neuron  = findSimlarV2(classData, Mdl, w_to_merge, indNeuron, s);
                goneNeurons = [goneNeurons neuron];
                % don't include already proceeded neurons -- do the same to
                % fineMerging function. Add another filter to get rid of
                % processed neurons.
                if ~isempty(neuron)> 0
                    for n=1 : length(neuron)
                        classData.w(n,:)= w_to_merge+classData.nbmerges(n)...
                          *classData.w(n,:)/(1+classData.nbmerges(n));
                        classData.theta(n)= theta +classData.nbmerges(n)*...
                        classData.theta(n)/(1+classData.nbmerges(n));
                        classData.nbmerges(n)=1+ classData.nbmerges(n);
   
                    end 
                end
                
            end
        end
        % Filter Neurons 
        rNeurons = linspace(1, N, N);
        rNeurons = rNeurons(~ismember(rNeurons, goneNeurons));
        repos.(classes{class}).w = classData.w(rNeurons, :);
        repos.(classes{class}).theta = classData.theta(rNeurons);
        repos.(classes{class}).nbmerges = classData.nbmerges(rNeurons);
        
    end
end
% Loop over all elements from each class 
% Merge classes 
% Update Repos 
% Stop when there is no more close neurons 



end

