function [ scaled_data ] = scaleCol( data, lower, upper )
if size(data,2)==1
    data =data(:);% vectorize data 
end
m = size(data, 2);
n = size(data, 1);
min_col = repmat(min(data, [], 1, 'omitnan'), [n, 1]);
max_col = repmat(max(data, [], 1, 'omitnan'), [n, 1]);
upp_minus_lower = repmat((upper-lower),[n m]);
rep_low = repmat (lower, [n, m]);
max_minus_min = max_col -min_col;

scaled_data = ((data - min_col).*upp_minus_lower)./(max_minus_min) + rep_low;

% if lower < upper
%     scaled_data = (data - repmat(min(data, [], 2, 'omitnan'), [1, m])).*repmat((upper-lower),[n m])./...
%         (max(data, [], 2, 'omitnan')- min(data, [], 2, 'omitnan')) + repmat(lower,size(data,1), 1);
% else
%     scaled_data = (data-min(data, [], 2)).*repmat((lower-upper),size(data,1),1)./...
%         (max(data, [], 2, 'omitnan')-min(data, [], 2, 'omitnan')) + repmat(upper,size(data,1), 1);    
% end


end
