function [ training , testing ] = getTTdata( name ,k, format)
% Load data into testing and trainign
% input : -name is name of the dataset
%       : -k is the fold number to generate test data from it.
%       : -format is the data format to be readed.
% output:- training and testing data
if exist ('Data')== 7
    files = sprintf ( 'Data/*%s*', name );
    folderContent = dir (files);
else
    files = sprintf ( '*%s*', name );
    folderContent = dir (files);
end

training = [];
testing = [];
for i=1 : numel(folderContent)
    fileName = folderContent(i).name ;
    path = ['Data' '\' folderContent(i).name]; 
    fileNameSplited = strsplit (fileName, '_' );
    fileNameSplited = strsplit (fileNameSplited{2}, '.' );
    
    if  str2num (fileNameSplited{1}) ==  (k)
        testing = dlmread ( path, format);
    else
        training = [training ; dlmread( path, format)];
    end
end

end

