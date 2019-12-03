function [ neuron ] = findSimlar2( w, l, theta, repos, Param )
% find a simlar neuron for merging  
% If the repos for the this label is empty. 

% Intialize a distance matrix for the data 
ind_repos = find(repos.label ==l);
if isempty(ind_repos)
   neuron=[];
   return;
end
N = length(ind_repos);

l_dist=zeros(N,1);
% Loop for each neuron in the repos.
for i=1:N
    ind_w = ind_repos(i);
    if  strcmp(Param.dist, 'euclidean')
        l_dist(i)=norm(w'-repos.w(ind_w, :))/sqrt(length(w)*0.9);
        l_dist(i)=norm(theta-repos.theta(ind_w, :));
    else
        l_dist(i) = pdist2(w',repos.w(ind_w,:), Param.dist)...
            /sqrt(length(w)*0.9);
    end   
end
%l_dist
% Fidn the closest neuron 
[~,min_ind_dist]=min(l_dist);
ind = ind_repos(min_ind_dist);

% Retrun the index of the closest neuron if its below s 
if  l_dist(min_ind_dist)< Param.s
    neuron=ind;
else
    neuron=[];
end
