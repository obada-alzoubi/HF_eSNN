function [ repos ] = stdp(spikes,repos,l,Param)
% why we add 0.03 to both values in ind of w 
[~,index]=sort(spikes);


%% Find the spking neurons in repos
 fields = fieldnames(repos);
for j=2:numel(fields)
    [ actives] = propagate_fast_stdp(spikes,repos,Param);
    if ~isempty(actives.(fields{j}).ind)
        str=sprintf('Class%d',l);
        if strcmp(str,fields{j})
            repos.(fields{j}).w(actives.(fields{j}).ind,:)=repos.(fields{j}).w(actives.(fields{j}).ind,:) ;
        else
            repos.(fields{j}).w(actives.(fields{j}).ind,:)=repos.(fields{j}).w(actives.(fields{j}).ind,:) ;
        end
    end 
    
end

end

