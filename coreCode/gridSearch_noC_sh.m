function [ best_param ] = gridSearch_noC_sh( data, Param )

% Input:
%       -data: data to find optimal config. for it.
%       -Param: General Param for the algorithm.
% Output:
%       -Best m, s and c values and the corresponding accuracies.
% 
s_range = Param.search.s_range;
m_range = Param.search.m_range;
nTraining = size(data, 1);
gridSize = length(s_range)*length(m_range);
best_param = zeros(gridSize, 3);
Acc = 0;
grid = zeros(gridSize, 2);
c =1 ;
Params ={};
% initialize the searching grid
for s_t =s_range
        for m_t = m_range
            grid(c, :) = [s_t m_t];
            Param.s= grid(c, 1);
            Param.m= grid(c, 2);
            Params{c} = Param;
            c = c +1;
        end
end

% Loop over all possible vlaues 
lim = round(nTraining*0.8);
parfor i=1:gridSize
    
    fprintf('iteration %d \n', i);
    % Train
    [ repos, ~, ~] = findWeight(data(1:5000, :), Params{i});
    % Test
    s =silhouette(repos.w, repos.label);
    mean_s = mean(s);
    % Find the compression in the mode

    % Write results
    best_param(i, :) = [grid(i,1) grid(i,2)  mean_s];
    fprintf('s=%d--- m=%d --- Acc=%0.2f\n'...
        ,grid(i,1), grid(i,2), mean_s );
end

end