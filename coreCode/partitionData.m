function [ info ] = partitionData( data , k, format, name )
% divide the data into k subset and save them. 
% input:-data : the data in m*n format.
%       -k    : the number of partitions. 
%       -format : either comma or space delimiter output. 
%       -name  : the output files.
% outupt:- some statisitcs about the classes distributions in each
% partition. 
%indices = randi([1,5],size(Data,1),1);
N = size(data, 1);
indices = crossvalind('Kfold', N, k);
mkdir('Data')
info = cell(k,2);
%Shuffle Data 
idx = randperm(length(data));
data = data ( idx, : );
for i=1:k
    test = (indices == i); 
    labels =data (test,end );
    u_lables = unique ( labels );      %list of elements
    count=hist(labels,u_lables);
    info{i ,1} = count / length (labels);
    info{i,2} = u_lables;
    temp_data = data (test ,: );
    outputFile = sprintf ('Data/%s_%d.dat', name , i);
    dlmwrite (outputFile, temp_data, 'delimiter', format );
     
        
end


end

