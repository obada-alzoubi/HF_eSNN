function [ best_param ] = gridSearchforBeta2(data, Param )

% Input:
%       -data: data to find optimal config. for it.
%       -Param: General Param for the algorithm.
% Output:
%       -Best m, s and c values and the corresponding accuracies.
% 
beta_range = Param.search.beta_range;
nGRF = Param.search.nGRF;
nTraining = size(data, 1);
gridSize = length(beta_range)*length(nGRF);
best_param = zeros(gridSize,4);
Acc = 0;
grid = zeros(gridSize, 2);
c =1 ;
Params ={};

for beta_t =beta_range
    for nGRF_t = nGRF
            grid(c, :) = [beta_t nGRF_t];
            Param.Beta= grid(c, 1);
            Param.nbfields= grid(c, 2);
            Params{c} = Param;
            c = c +1;
    end
end



lim = round(nTraining*0.8);
parfor i=1:gridSize
    
    fprintf('iteration %d \n', i);
    % Train
    [repos, ~, ~] =train_eSNN4(data(1:lim, :), Params{i});
    % Test
    [acc, ~]=test_eSNN3( repos,data(lim:10000,: ),Params{i});
    % Find the compression in the mode
    nNeurons = length(repos.theta); %
    comp = (1- (nNeurons/lim));
    % Write results
    best_param(i, :) = [grid(i,1) grid(i,2) acc comp];
    fprintf('Beta=%d --- nGRF=%d --- Acc=%0.2f ---comp.=%0.2f\n'...
        ,grid(i,1), grid(i,2), acc, comp)
end

