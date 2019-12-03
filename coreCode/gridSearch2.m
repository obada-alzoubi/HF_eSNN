function [ best_param ] = gridSearch2( data, Param )

% Input:
%       -data: data to find optimal config. for it.
%       -Param: General Param for the algorithm.
% Output:
%       -Best m, s and c values and the corresponding accuracies.
% 
s_range = Param.search.s_range;
c_range = Param.search.c_range;
m_range = Param.search.m_range;
nTraining = size(data, 1);
gridSize = length(s_range)*length(c_range)*length(m_range);
best_param = zeros(gridSize,5);
Acc = 0;
grid = zeros(gridSize, 3);
c =1 ;
Params ={};
% initialize the searching grid
for s_t =s_range
    for c_t = c_range
        for m_t = m_range
            grid(c, :) = [s_t c_t m_t];
            Param.s= grid(c, 1);
            Param.c= grid(c, 2);
            Param.m= grid(c, 3);
            Params{c} = Param;
            c = c +1;
        end
    end
end

% Loop over all possible vlaues 
lim = round(nTraining*0.8);
for i=1:gridSize
    
    fprintf('iteration %d \n', i);
    % Train
    [repos, ~, ~] =train_eSNN4(data(1:lim, :), Params{i});
    % Test
    [acc, ~]=test_eSNN3( repos,data(lim:10000,: ),Params{i});
    % Find the compression in the mode
    nNeurons = length(repos.theta); %
    comp = (1- (nNeurons/lim));
    % Write results
    best_param(i, :) = [grid(i,1) grid(i,2) grid(i,3) acc comp];
    fprintf('s=%d --- c=%d --- m=%d --- Acc=%0.2f ---comp.=%0.2f\n'...
        ,grid(i,1), grid(i,2),grid(i,3),acc, comp)
end

end
