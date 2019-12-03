 function [ repos ] = fineMerging2( repos, Param  )
% Merge similar neurons
s= Param.s;
classes  =  unique(repos.label);

for class = classes
    % Get the size of the repos
    N_all = length(repos.label);
    % General filter to update repos with new wieghts
    ture_all = true(N_all, 1);
    % get the indices of samples from this class 
    ind_class = find(repos.label==class);
    % mark the class's samples as invlaid
    ture_all(ind_class)=false;
    % Get the number of samples for this class
    N = length(ind_class); 
    % Get all the information for this class 
    classData.w = repos.w(ind_class);
    classData.label = repos.label(ind_class);
    classData.theta = repos.theta(ind_class);
    classData.psp = repos.psp(ind_class);
    classData.nbmerges = repos.nbmerges(ind_class);
    % add field to track the processed neurons 
    classData.processed = false(1, N);
    goneNeurons = [];
    % contruct KDTree object
    Mdl = KDTreeSearcher(classData.w);
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
    % filter out all samples for this class 
    repos.w = repos.w(ture_all, :);
    repos.theta = repos.theta(ture_all);
    repos.psp = repos.psp(ture_all);
    repos.nbmerges = repos.nbmerges(ture_all);
    repos.label = repos.label(ture_all);
    % update the repos with new samples for this class 
    repos.w = [ repos.w; classData.w(rNeurons, :)];
    repos.theta = [repos.theta; classData.theta(rNeurons)];
    repos.psp = [repos.psp; classData.psp(rNeurons)];
    repos.nbmerges = [repos.nbmerges; classData.nbmerges(rNeurons)];
    repos.label = [repos.label; classData.label(rNeurons)];

    
end

end

