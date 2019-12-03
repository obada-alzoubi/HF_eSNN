function [ best_param ] = gridSearch( data, Param )

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

K = 5;

indices = crossvalind('Kfold', nTraining, 5);

parfor i=1:gridSize
    fprintf('iteration %d \n', i)
    accFold = 0;
    compFold = 0;
    for fold =1:K
        test = (indices == fold); train = ~test;
        [repos, ~, ~] =train_eSNN3(data(train, :), Params{i});
        [acc, ~]=test_eSNN2( repos,data(test(1:200),: ),Params{i} );
        % Find the compression in the model
        cl = fieldnames(repos);
        nNeurons =0;
        c= 1;
        for j=1 : numel(cl)
          if ~isempty (strfind( cl{j}, 'Class'))
              n = size(repos.(cl{j}).w, 1);
              %fprintf ('num neurons for %s is: %d \n' ,cl{j}, n)
              nNeurons = nNeurons +n ;
              c = c +1;
          end
        end

        comp = (1- (nNeurons/nTraining));
        %if acc > 0
       accFold = accFold + acc;
       compFold = compFold +comp;
        %end
    end
    
    best_param(i, :) = [grid(i,1) grid(i,2) grid(i,3) accFold/5 compFold/5];
    fprintf('s=%d --- c=%d --- m=%d --- Acc=%0.2f ---comp.=%0.2f\n'...
        ,grid(i,1), grid(i,2),grid(i,3),acc,comp)
end
      
save('best_param_test2.mat','best_param')
end

