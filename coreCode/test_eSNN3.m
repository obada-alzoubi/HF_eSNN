function [ Accuracy, predicted_labels ] = test_eSNN3( repos,testData,Param )
samples=testData(:,1:end-1);
label=testData(:,end);


N=size(samples,1); % Number of testing smaples
nb_correct = 0;
predicted_labels = zeros(N,1);
% Get RCF Params
[ sigma, mu, rcf_mu ] = calcRCFParams( Param);
%parfor_progress(floor(N/20000)); 
for i=1:N
    l=label(i);
    %Print some progress 
    if mod(i,500)==0
        fprintf('Acc for testing is %0.2f for %d \n',100*(nb_correct/i), i);
  %      parfor_progress;
    end
    %spikes=populationEncoding(samples(i,:),Param);
     spikes = populationEncoding3(samples(i,:), Param, sigma, mu, rcf_mu);
    [~, ~, class_label,~] = propagate_fast2(spikes,repos,Param);
    clear spikes
    % Store the predicted class for later usages
    if ~ isempty(class_label)% non of the output neurons emittied a spike 
        predicted_labels(i)=class_label;
    else
        predicted_labels(i)=NaN;
        
    end
    if class_label==l
         nb_correct = nb_correct + 1;
    end

end
%hold off
Accuracy=nb_correct/size(testData,1);
%parfor_progress(0);

end

