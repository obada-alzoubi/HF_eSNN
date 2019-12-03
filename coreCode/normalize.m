function [ dataNorm ] = normalize( data )
% Nomalize data between -1 and 1
%# get max and min
maxVec = max(data,[],1);
minVec = min(data,[],1);
%# normalize to -1...1
dataNorm=[];
for i=1:size(data,2)
    vec = ((data(:,i)-minVec(i))./(maxVec(i)-minVec(i)) - 0.5 ) *2;
    dataNorm=[dataNorm vec];
end 


end

