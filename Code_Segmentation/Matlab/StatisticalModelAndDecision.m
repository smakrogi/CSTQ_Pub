function region_ids = StatisticalModelAndDecision(Joint_Measure, pdf_threshold, Params)
% Authors:
% S. Makrogiannis, MIVIC, PEMACS, DESU <smakrogiannis@desu.edu>
% Use MAM and Area to determine the background.

Params.data_preproc_method = 'z-scores'; % options: {'none','z-scores','normalize'}

Joint_Measure = Joint_Measure(:,1:3);

% Prepare the data
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

switch Params.fgnd_bgnd_method
    case 'normal_pdf_joint'
        [Probability, z_centroid] = ParametricLikelihoodEstimation(Joint_Measure, ...
            Joint_Measure);
        [centroid_prob, idx_mean_vector] = max(Probability);
%         centroid = [area(idx_mean_vector), motion_activity(idx_mean_vector)];
        z_centroid = Joint_Measure(idx_mean_vector,:);
    case 'kde_pdf_joint'
        Probability = NonParametricLikelihoodEstimation(Joint_Measure, ...
            Joint_Measure, Params.FB_Sigma);
        [centroid_prob, idx_mean_vector] = max(Probability);
%         centroid = [area(idx_mean_vector), motion_activity(idx_mean_vector), ...
%             motion_field_mag(idx_mean_vector)];
        z_centroid = Joint_Measure(idx_mean_vector,:);
end

% Scale likelihood estimates.
% centroid_prob = centroid_prob / sum(Probability);
% Probability = Probability / sum(Probability);

% Compute Mahalanobis distances.
[mahal_dist_vector] = MahalanobisDistance(Joint_Measure, ...
    Joint_Measure, z_centroid);

% Determine threshold usinig chi-squared test, or interquartile_range.
dimensionality = numel(z_centroid);
dist_theshold = chi2inv(0.95, dimensionality);

% Select foreground regions.
region_ids = (mahal_dist_vector < dist_theshold);
% region_ids = (Probability > pdf_threshold);
if sum(region_ids)==numel(region_ids)
    [max_dist, idx_max_dist] = max(mahal_dist_vector);
    region_ids(idx_max_dist) = 0;
end

% Display results.
if Params.display
    switch dimensionality
        case 2
            figure(1); subplottight(3,5,10);
            stem3(Joint_Measure(:,1),Joint_Measure(:,2),Probability, '.b'); hold on;
            stem3(Joint_Measure(region_ids,1),Joint_Measure(region_ids,2 ),Probability(region_ids), '.g');
            stem3(z_centroid(1), z_centroid(2), centroid_prob, 'og', 'MarkerFaceColor', '#EDB120');
            text(z_centroid(1), z_centroid(2), centroid_prob, ...
                (['(',num2str(z_centroid(1),'%.1f'),',',num2str(z_centroid(2),'%.2f'),',',...
                num2str(centroid_prob,'%.3f'),')']))
            hold off;
            title('Joint PMF','FontSize',10);
            xlabel('Feature #1','FontSize',10);
            ylabel('Feature #2','FontSize',10);
            zlabel('Probability','FontSize',10);
            grid on; grid minor;
        case 3
            figure(1); subplottight(3,5,10);
            bubblechart3(Joint_Measure(:,1),Joint_Measure(:,2),Joint_Measure(:,3), ...
                Probability,'b','MarkerFaceAlpha',0.20); 
            bubblesize(gca,[1 20]); hold on;
            bubblechart3(Joint_Measure(region_ids, 1),Joint_Measure(region_ids,2),Joint_Measure(region_ids,3), ...
                Probability(region_ids), 'g', 'MarkerFaceAlpha',0.20);
            bubblesize(gca,[1 20]); 
            scatter3(z_centroid(1), z_centroid(2), z_centroid(3), 'og', 'MarkerFaceColor', '#EDB120');
            text(z_centroid(1), z_centroid(2), z_centroid(3), ...
                (['(',num2str(z_centroid(1),'%.1f'),',',num2str(z_centroid(2),'%.2f'),',',...
                num2str(z_centroid(3),'%.2f'),')']))
            hold off;
            title('Joint PMF','FontSize',10);
            xlabel('Feature #1','FontSize',10);
            ylabel('Feature #2','FontSize',10);
            zlabel('Feature #3','FontSize',10);
            grid on; grid minor;
        otherwise
    end
end


end