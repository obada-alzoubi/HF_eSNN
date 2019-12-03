function [ neuron ] = findSimlarV2(classData, Mdl, w_to_merge, indNeuron, s)
% find the simlar neuron for merging 
%w_all= classData.w;
%Mdl = KDTreeSearcher(w_all);
[Idx,D] = knnsearch(Mdl,w_to_merge,'K',2,'IncludeTies',true);
neuron =[];
% We want the KD-Tree algorithm to return only we closest element, but to
% avoid mutliple training on the data for KD-Tree, we include all elemnts
% in the finding k- nearest elemets. But agian, we need only one element,
% so for sure, the algorithm will return the element bu itself and may be
% other elements.
l1 = length(D{1});
if l1 >=2
    % we have several neurons that are exactly similar to w_to _merge
    Dist = D{1};
    Ind = Idx{1};
    Ind = Ind (Ind ~= indNeuron);
    Dist = Dist(Idx{1}~=indNeuron); 
    filterPrecessed = ~classData.processed(Ind);
    % Becuse Ind was changed we used Idx
    Ind = Ind(filterPrecessed);
    Dist = Dist(filterPrecessed);

    [sortedDist ,sortedInd] = sort(Dist);
    exactlySame  = find (sortedDist ==0);
        % We have similar neuron with exact weights
        % We might change the behavior of if the neurons is exactly the
        % same; Avoid correction process or eliminate the neuron itself.
    if ~isempty(exactlySame) 
        neuron = Ind(sortedInd(exactlySame));
    else
        if ~isempty(sortedDist)
            if sortedDist(1) < s
                neuron = sortedInd(1);
                % Several neurons are similar with same distance
                for r=2 :length (sortedDist)
                    if sortedDist(r) == sortedDist(1) 
                        neuron = [neuron Ind(sortedInd(r))];
                    end
                end
            else
                neuron = [];
            end
        else
            neuron = [];
        end

    end
end    




