function [SelectedFeatureMap, SelectedScaleMap, selected_scale] = AutoFeatureScaleSelection(FeatureMaps, Params)
% S. Makrogiannis, MIVIC, PEMACS, DESU <smakrogiannis@desu.edu>
% Find regional maxima on DoDiff_Map, then find the maximizer wrt
% scale.


debug = false;
second_deriv_thres = 0.05;
CDF_Iref = 0.95;


% Given a scale space stack of features.
fprintf('Scale selection\n');
SelectedScaleMap = zeros(size(FeatureMaps,1),size(FeatureMaps,2));


% Take the absolute or squared values.
FeatureMaps = abs(FeatureMaps);


% Find regional maximum points on the image plane.
RegionalMaximaMaps = zeros(size(FeatureMaps));
switch Params.regional_maxima_detector
    case 'image_extended_last_scale'
        %       [counts,edges] = histcounts(FeatureMaps(:,:,end), 1024);
        %         feature_threshold = otsuthresh(counts) * edges(end);
        feature_threshold = Set_Iref_From_CDF_Iref(FeatureMaps(:,:,end), CDF_Iref, Params);
        RegionalMaximaMapsSingleScale = imextendedmax(FeatureMaps(:,:,end), ...
            feature_threshold);
        RegionalMaximaMaps = repmat(RegionalMaximaMapsSingleScale, ...
            [1,1,size(FeatureMaps,3)]);
    case 'image_extended_all_scales'
        %         feature_threshold = 1;
        %         [counts,edges] = histcounts(FeatureMaps, 1024);
        %         feature_threshold = otsuthresh(counts) * edges(end);
        feature_threshold = Set_Iref_From_CDF_Iref(FeatureMaps, CDF_Iref, Params);
        RegionalMaximaMaps = imextendedmax(FeatureMaps, feature_threshold);
    case 'image_extended_separate_scales'
        % feature_threshold = 1;
        for ii=1:size(FeatureMaps,3)
            %             [counts,edges] = histcounts(FeatureMaps(:,:,ii), 1024);
            %             feature_threshold = otsuthresh(counts) * edges(end);
            feature_threshold = Set_Iref_From_CDF_Iref(FeatureMaps(:,:,ii), CDF_Iref, Params);
            RegionalMaximaMaps(:,:,ii) = imextendedmax(FeatureMaps(:,:,ii), feature_threshold);
        end
    case 'choose_last_scale'
        feature_threshold = Set_Iref_From_CDF_Iref(FeatureMaps(:,:,end), CDF_Iref, Params);
        RegionalMaximaMaps(:,:,end) = imextendedmax(FeatureMaps(:,:,end), feature_threshold);
end


% Follow feature changes across scales.
if strcmpi(Params.regional_maxima_detector, 'choose_last_scale')
    idx_maxima = find(RegionalMaximaMaps);
    n_maxima = numel(idx_maxima);
    idx_scales = 1:size(FeatureMaps,3);
    feature_vector = zeros(n_maxima, numel(idx_scales));
    for ii=1:n_maxima
        [row,col,scale] = ind2sub([size(FeatureMaps,1),size(FeatureMaps,2)],idx_maxima(ii));
        feature_vector(ii,scale) = FeatureMaps(row,col,scale);
    end
    selected_scale = size(FeatureMaps,3);
    SelectedScaleMap = selected_scale * RegionalMaximaMaps(:,:,end);
else
    idx_maxima = find(sum(RegionalMaximaMaps,3));
    n_maxima = numel(idx_maxima);
    idx_scales = 1:size(FeatureMaps,3);
    feature_vector = zeros(n_maxima, numel(idx_scales));
    for ii=1:n_maxima
        [row,col,scale] = ind2sub([size(FeatureMaps,1),size(FeatureMaps,2)],idx_maxima(ii));
        feature_vector(ii,:) = FeatureMaps(row,col,idx_scales);
        
        % Choose the maximizer as the localization scale.
        [~, idx_max] = max(feature_vector(ii,:));
        SelectedScaleMap(row,col) = idx_max;
    end
end


% Choose scale based on global feature properties.
mean_feature_maxima = mean(feature_vector);
[fx,~] = gradient(feature_vector);
[fxx,~] = gradient(fx);
mean_fx = mean(fx);
mean_fxx = mean(fxx);

switch Params.scale_selection_rule
    case 'max_average'
        % selected_scale = median(SelectedScaleMap(idx_maxima));
        [~,selected_scale] = max(mean_feature_maxima);
        
        fprintf('Average feature maxima values: ');
        fprintf(' %g ', mean_feature_maxima);
        fprintf('\n');
    case 'second_deriv'
        [max_mean_fxx, idx_max_mean_fxx] = max(mean_fxx);
        scaled_fxx = mean_fxx / max_mean_fxx;
        % Ignore points to the left of max mean.
        scaled_fxx(1:idx_max_mean_fxx) = 1;
        candidate_scales = find(scaled_fxx < second_deriv_thres);
        if isempty(candidate_scales)
            candidate_scales = numel(scaled_fxx);
        end
        selected_scale = max(min(candidate_scales), 1);
%         selected_scale = idx_max_mean_fxx;
        fprintf('Average feature 2nd deriv pct values: ');
        fprintf(' %g ', scaled_fxx);
        fprintf('\n');
end
fprintf('Selected scale: %d\n', selected_scale);


% Choose the feature map according to criterion.
SelectedFeatureMap = FeatureMaps(:,:,selected_scale);

if strcmpi(Params.regional_maxima_detector, 'image_extended_all_scales')
    SelectedScaleMap = RegionalMaximaMaps(:,:,selected_scale);
end


% Display information.
if Params.display && debug
    figure,
    subplot(221), imagesc(imtile(RegionalMaximaMaps,'BorderSize',[5, 5])); colorbar; axis image;
    subplot(222), plot(feature_vector');
    subplot(223), plot(mean_feature_maxima, 'k');
    hold on; plot(mean_fx);
    hold on; plot(mean_fxx, 'g');
    legend({'original', '1st deriv', '2nd deriv'})
    subplot(224), imagesc(SelectedScaleMap), axis image, colorbar
end


% To Do: scale fusion.

end