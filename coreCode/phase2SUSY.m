%% Param
warning('off','all')
fprintf ('---------------------- Start--------------------- \n')
clc;
Param.m=0.9;
Param.c=0.7;
Param.s=0.6;
Param.I_min=-1;
Param.I_max=1;
Param.nbfields=20;
Param.Beta=1.5;
rng(1234)
id=1;
%%
addpath('matlab')
addpath('data')
addpath('coreCode')
%% Read Data
nWorkers = 400;
parWorkers = 10;
nTraining =1;
fOutput = 'SUSY_perfect' ;
testFilename = sprintf('data/test%s.mat', fOutput);

%% Parallel Cluster Configuration
tic 

t1 =180*60;  
clear repos w_all theta_all psp_all data_all label_all
%% Fine merging 
fprintf('Execution time of Phase is %0.2f mins:\n', floor(t1/60))
fprintf('Phase two ... starting \n')
fileName = sprintf('data/mainRepos_%s.mat',fOutput);
%load(fileName)
%parfor i= 1:nWorkers
%    mainRepos{i,1} = fineMerging( mainRepos{i,1}, Param );
    
%end
%fprintf('Finishing phase2 ....  \n')

%% Updata final repos
% First get all available classes in the data
%classes= {};
%c =1;
%for i = 1:nWorkers
%      cl = fieldnames(mainRepos{i,1});
%      for j=1 : numel(cl)
%          if ~isempty (strfind( cl{j}, 'Class'))&& ~any(strcmp(classes,  cl{j}))
%              classes{c} =  cl{j};
%              c = c +1;
%          end
%      end    
%end

%finalRepos= [];
%finalRepos.uniquesTrainLabels =[];
%for j = 1:numel(classes)
%     w_all = [];
%     theta_all =[];
%     psp_all = [];
%     nbmerges_all = [];
%     label_all = []; 
%     data_all = [];
%    for i = 1 : nWorkers
         % Loop over each class from each repos.
%         w_all = [w_all ;  mainRepos{i,1}.(classes{j}).w];
%         theta_all = [ theta_all ; mainRepos{i,1}.(classes{j}).theta];
%         psp_all = [psp_all ; mainRepos{i,1}.(classes{j}).psp] ;
%         nbmerges_all = [nbmerges_all ; mainRepos{i,1}.(classes{j}).nbmerges];
%         label_all = [label_all ;  mainRepos{i,1}.(classes{j}).label];
%         data_all =[];
      
%    end
%    finalRepos.(classes{j}).w = w_all;
%    finalRepos.(classes{j}).theta = theta_all;
%    finalRepos.(classes{j}).psp = psp_all;
%    finalRepos.(classes{j}).nbmerges = nbmerges_all;
%    finalRepos.(classes{j}).label = unique(label_all);
%    finalRepos.(classes{j}).data = [];
%    finalRepos.uniquesTrainLabels = [finalRepos.uniquesTrainLabels unique(label_all)];
%end
%finalRepos.uniquesTrainLabels = unique(finalRepos.uniquesTrainLabels);
%t2 = toc;
%fprintf('Time before testing: %d \n',t2)
fileName = sprintf('data/finalRepos%s.mat',fOutput);
%save(fileName, 'finalRepos','-v7.3')
load(fileName)
clear mainRepos w_all psp_all theta_all nbmerges_all
test_Access = matfile(testFilename);
batchSize = floor(size(test_Access.dataTs, 1)/nWorkers);
batchSize = 500;
fprintf('Batch Size  for testing is %d \n', batchSize)

%% Test data 
% load test data
fprintf('Start testing phase \n')
%test_Access = matfile(testFilename);
allAcc = zeros(nWorkers, 1);
for p=1:nWorkers
    start = (p-1)*(batchSize) +1;
    last =  p*batchSize ; 
    testData = test_Access.dataTs(start: last, :);
    [allAcc(p), ~]=test_eSNN( finalRepos,testData,Param );   
     if mod(p, 20)==0
       fprintf('w. n. %d is done \n', p)
     end
end
 % Overall all accuracy 
Accuracy = sum(allAcc(:))/nWorkers;
%  Print Statisitcs about the classes 
cl = fieldnames(finalRepos);
nNeurons =0;
c= 1;
for j=1 : numel(cl)
  if ~isempty (strfind( cl{j}, 'Class'))
      n = size(finalRepos.(cl{j}).w, 1);
      fprintf ('num neurons for %s is: %d \n' ,cl{j}, n)
      nNeurons = nNeurons +n ;
      c = c +1;
  end
end 
%
comp = (1- (nNeurons/nTraining));
fprintf ('Comp. ratio is %0.2f \n', comp)
fprintf('Time: %d - accuracy: %0.4f \n',t2,Accuracy)
res = [ id t1 t2 parWorkers nWorkers Accuracy comp];
dlmwrite(fOutput, res,'-append')
fprintf ('---------------------- Done--------------------- \n')
