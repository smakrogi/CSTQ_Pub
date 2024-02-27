function region_ids = ClassifierDecision(Joint_Measure, fb_model, Params)
% Authors:
% S. Makrogiannis, MIVIC, PEMACS, DESU <smakrogiannis@desu.edu>
% Use multiple features to determine the background.

% Prepare the data
Params.data_preproc_method = 'z-scores'; % options: {'none','z-scores','normalize'}

switch Params.data_preproc_method
    case 'normalize'
        % Normalize the vector lengths.
        Joint_MeasureT = Joint_Measure';
        Joint_MeasureT = normcols(Joint_MeasureT);
        Joint_Measure = Joint_MeasureT';
    case 'z-scores'
        % Center and scale data to compute z-scores.
        Joint_MeasureT = Joint_Measure';
        mean_vector = mean(Joint_MeasureT, 2);
        Joint_MeasureT = (Joint_MeasureT - mean_vector);
        Joint_MeasureT = Joint_MeasureT ./ std(Joint_MeasureT,0,2);
        Joint_Measure = Joint_MeasureT';
    case 'none'
end


% Perform classification
dimensionality = numel(Joint_Measure(1,:));
[region_ids, probability] = predict(fb_model,Joint_Measure);


% Display results.
if Params.display
    %    figure(2);
    %    gplotmatrix(Joint_Measure,[],region_ids,{'green','blue'},'o',[],[]);
    switch dimensionality
        case 1
        case 2
            figure(1); subplottight(3,5,10);
            stem3(Joint_Measure(:,1),Joint_Measure(:,2),probability(:,2), '.b'); hold on;
            stem3(Joint_Measure(region_ids~=0,1),Joint_Measure(region_ids~=0,2),probability(region_ids~=0,2), '.g');
            hold off;
            title('Joint PMF','FontSize',10);
            xlabel('Feature #1','FontSize',10);
            ylabel('Feature #2','FontSize',10);
            zlabel('Probability','FontSize',10);
            grid on; grid minor;
        otherwise
            figure(1); subplottight(3,5,10);
            bubblechart3(Joint_Measure(:,1),Joint_Measure(:,2),Joint_Measure(:,3), ...
                probability(:,2),'b','MarkerFaceAlpha',0.20);
            bubblesize(gca,[1 20]); hold on;
            bubblechart3(Joint_Measure(region_ids~=0,1),Joint_Measure(region_ids~=0,2),Joint_Measure(region_ids~=0,3), ...
                probability(region_ids~=0,2), 'g', 'MarkerFaceAlpha',0.20);
            bubblesize(gca,[1 20]);
            hold off;
            title('Joint PMF','FontSize',10);
            xlabel('Feature #1','FontSize',10);
            ylabel('Feature #2','FontSize',10);
            zlabel('Feature #3','FontSize',10);
            grid on; grid minor;
    end

end


end