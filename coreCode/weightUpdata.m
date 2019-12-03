function [repos] = weightUpdata( neuron,repos,w,theta,c,l )

str=sprintf('Class%d',l);
WeightCount = zeros (length (w),1);
for i =1 : length (w)
    n = find(repos.(str).w(:,i) > 0);
    if length(n)> 10 || w (i) > 0.5
        repos.(str).w(n,i)=1.01*repos.(str).w(n,i); 
    end 
    for l=2:length(fieldnames(repos))
        fields= fieldnames(repos);
        f = fields{l};
        if ~strcmp (f ,str )
                o = find(repos.(f).w(:,i)>0);
                if length (o) >10
                    repos.(f).w(o,i)=0.99*repos.(f).w(o,i); 
                end

        end
    end
end
for j=1: size ( repos.(str).w,1)
     repos.(str).theta(j) = c* sum(repos.(str).w(j,:).* repos.(str).w(j,:));
end
end