function [ neuron ] = findSimlar( w,l,s,repos, Param )
% find a simlar neuron for merging 
str=sprintf('Class%d',l);
% If the repos for the this label is empty. 
if isempty(repos.(str).w)
   neuron=[];
   return;
end
% Intialize a distance matrix for the data 
N=size (repos.(str).w,1);
l_dist=zeros(N,1);
% Loop for each neuron in the repos.
for i=1:N
    if  strcmp(Param.dist, 'euclidean')
        l_dist(i)=norm(w'-repos.(str).w(i,:))/sqrt(length(w)*0.9);
    else
        l_dist(i) = pdist2(w',repos.(str).w(i,:), Param.dist)...
            /sqrt(length(w)*0.9);
    end   
end
% Fidn the closest neuron 
[~,ind]=min(l_dist);
% Retrun the index of the closest neuron if its below s 
if  l_dist(ind)<s
    neuron=ind;
else
    neuron=[];
end

