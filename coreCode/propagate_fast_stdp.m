function [ actives ] = propagate_fast_stdp(spikes,repos,Param)

[~,index]=sort(spikes);
fields = fieldnames(repos);
actives=[];
activesFound=[];

for j=2:numel(fields)
       actives.(fields{j}).psp=0;
       actives.(fields{j}).ind=[];
end
active_neurons=[];
for i=1:size(spikes,2)
    
    for j=2:numel(fields)
        if ~isempty(repos.(fields{j}).w)
           actives.(fields{j}).psp= actives.(fields{j}).psp + repos.(fields{j}).w(:,index(i))*power(Param.m,i-1);

           active_neurons=find( actives.(fields{j}).psp >repos.(fields{j}).theta);
        end
       if ~isempty(active_neurons)
            actives.(fields{j}).ind=[actives.(fields{j}).ind ;active_neurons];
            activesFound=1;
            
       end
       if ~isempty(activesFound)
           return;
       end 
       

    end
   
end



end

