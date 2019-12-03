function [ w,theta ] = train_smaple( spikes,m,c,max_response_time )
% compute the weights and the threshold for the sample
[~,index]=sort(spikes);% Get the sorted indecies
%%%
%%%%
%%%%%
numSipkes=size(spikes,2);% check here
%%%%%
%%%%
%%%
%
w=zeros(numSipkes,1);

for i=1:numSipkes
    %w(index(i))=power(m,i-1);
     w(index(i))=exp(-i/numSipkes);

end 

lateIndecies=find(spikes >max_response_time);% find late spikes and correct them  
w(lateIndecies)=0;
% u_max=0;
% for i=1:numSipkes
%     u_max=u_max+(w(i)/abs(w(i)))*w(i)*w(i);
% end
u_max=sum(w.*w);
theta = u_max;
end

