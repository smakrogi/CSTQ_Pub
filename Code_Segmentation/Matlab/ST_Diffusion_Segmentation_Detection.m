function  [Motion_Mask, Global_Max, Global_Min, Iref, CDF_Iref, Itest, Local_Min, FeatureMap, BackgndImageScaled, DiffusedFrame] =...
    ST_Diffusion_Segmentation_Detection(Global_Max, Global_Min, Iref, CDF_Iref, frame_index, train_frame_index, ...
    Training_Data, Nom, nb_all_images, nb_train_images, denoise_net, BackgndImageScaled, Params)
% F. Boukari, MIVIC, PEMACS, DESU
% S. Makrogiannis, MIVIC, PEMACS, DESU <smakrogiannis@desu.edu>

%% Preprocess compute features and segment frames.
[Global_Max, Global_Min, Iref, CDF_Iref, Itest, Local_Min, FeatureMap, BackgndImageScaled, DiffusedFrame, ...
    SpatioTemporalWatershedMap, SpatioTemporalGradientMap, SelectedScaleMap, Displacement_Field_Mag, UV] =...
    PreprocessComputeFeaturesSegment(Global_Max, Global_Min, Iref, CDF_Iref, frame_index, train_frame_index, ...
    Training_Data, Nom, nb_all_images, nb_train_images, denoise_net, BackgndImageScaled, Params);

% Display scale selection and segmentation outputs.
if Params.display
    figure(1); subplottight(3,5,6);
    imagesc(labeloverlay(FeatureMap/max(FeatureMap(:)),SelectedScaleMap, ...
        'Transparency', 0.25, 'Colormap', 'hot')); axis image;
    title(['Frame #', num2str(frame_index), '/', num2str(nb_all_images), ...
        ', Selected Map and Critical Points']);

    figure(1); subplottight(3,5,7);
    imagesc(DiffusedFrame/max(DiffusedFrame(:))); axis image; hold on;
    h = vis_flow(UV(:,:,1),UV(:,:,2)); hold off;
    title(['Frame #', num2str(frame_index), '/', num2str(nb_all_images), ...
        ', DiffusedFrame and Displacement Field']);

    figure(1); subplottight(3,5,8);
    imagesc(labeloverlay(DiffusedFrame/max(DiffusedFrame(:)),SpatioTemporalWatershedMap, ...
        'Transparency', 0, 'IncludedLabels', 0, 'Colormap', 'hot')); axis image;
    %         'Transparency', 0.75)); axis image;
    title(['Frame #', num2str(frame_index), '/', num2str(nb_all_images), ...
        ', All S-T Regions']);
end

%% Separate foreground from background.
fprintf('Finding moving regions\n');

[Joint_Measure, Region_Stats] = ...
    ComputeRegionFeatures([], [], [], FeatureMap, Displacement_Field_Mag, ...
    DiffusedFrame, SpatioTemporalGradientMap, SpatioTemporalWatershedMap);

switch Params.fgnd_bgnd_method
    case {'cdf_mam', 'cdf_joint'}
        % Compute the scaled value corresponding to Iref
        switch Params.motion_activity_measure
            case 'original'
                scaled_Iref = Scale_Transform_Itest_or_Iref(Iref,Iref,Itest,Global_Max,...
                    Global_Min, Local_Min);
            case 'diffused'
                scaled_Iref = Set_Iref_From_CDF_Iref(DiffusedFrame, ...
                    Params.CDF_Thres, Params);
            case 'st_gradient'
                scaled_Iref = Set_Iref_From_CDF_Iref(SpatioTemporalGradientMap, ...
                    Params.CDF_Thres, Params);
            otherwise % all region-based descriptors.
                intensity_vector = Joint_Measure(:,2);
                scaled_Iref = Set_Iref_From_CDF_Iref(intensity_vector, ...
                    Params.CDF_Thres, Params);
        end
        
        if strcmpi(Params.fgnd_bgnd_method, 'cdf_mam')
            % For each labeled region get the mean intensity.
            foreground_region_ids = Joint_Measure(:,2) > scaled_Iref;
        else
            % Joint criteria using statistical ranking.
            foreground_region_ids = NonParametricRankingAndDecision(Joint_Measure, ...
                Params.CDF_Thres, Params);
        end
    case {'normal_pdf_joint','kde_pdf_joint'}
        % Joint criteria using multi-variate normal distribution model.
        foreground_region_ids = StatisticalModelAndDecision(Joint_Measure, ...
            Params.CDF_Thres, Params);
    case{'classifier'}
        classifier_filename = strcat('fb_classifier.mat');
        classifier_model = matlab.lang.makeValidName(strcat('fb_model_',Nom));
        load(classifier_filename, 'classifier_struct');
        foreground_region_ids = ClassifierDecision(Joint_Measure, ...
            classifier_struct.(classifier_model), Params);
end

Motion_Mask= zeros(size(DiffusedFrame,1),size(DiffusedFrame,2));
for region_id = 1:length(Region_Stats{1})
    if (foreground_region_ids(region_id))
        Motion_Mask(Region_Stats{1}(region_id).PixelIdxList) = 1;
    end
end

% Apply morphological operations to close the watershed lines.
se=strel('disk', 1);
%      Motion_Mask = imdilate(Motion_Mask,se);
Motion_Mask = imclose(Motion_Mask,se);

if Params.display
    % Display results.
    subplottight(3,5,9);
    imagesc(labeloverlay(DiffusedFrame/max(DiffusedFrame(:)),uint8(boundarymask(Motion_Mask)), ...
        'Transparency', 0, 'IncludedLabels', 1, 'Colormap', 'hot')); axis image;
    title(['Frame #', num2str(frame_index), '/', num2str(nb_all_images), ...
        ', S-T Regions after F/B separation']);
end

end