function [ w,theta ] = train_sample2( spikes, Param )
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

% for i=1:numSipkes
% 	if Param.useExp 
% 		w(index(i))=exp(-i/numSipkes);
% 	 else
% 		w(index(i))=power(Param.m,i-1);
% 	 end
% 
% end
reductio_factor = numSipkes*exp(-1/numSipkes);
i =1:numSipkes;
if Param.useExp 
    w(index(i))=exp(-(i-1)/numSipkes)/reductio_factor;
 else
    w(index(i))=power(Param.m,i-1);
 end
lateIndecies=find(spikes >Param.max_response_time);% find late spikes and correct them  
w(lateIndecies)=0;
u_max=sum(w.*w);
if Param.useThreshold
	theta = Param.c*u_max;
else 
	theta = u_max;
end
end

