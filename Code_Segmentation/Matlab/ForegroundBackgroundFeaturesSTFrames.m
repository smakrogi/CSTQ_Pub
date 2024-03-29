function[feature_computation_ST] = ForegroundBackgroundFeaturesSTFrames(Train_Data, ...
    Reference_Data, Nom, denoise_net, train_idx, ref_idx, Params)
%This function reads in silver truth frames and computes the foreground
%background features

nb_frames = numel(train_idx);
nb_ref_frames = numel(ref_idx);

%Increasing the label value to +1
for ii=1:nb_ref_frames
    Reference_ST_Data = Reference_Data{ii} + 1;
    Reference_Data{ii} = Reference_ST_Data;
end

csv_name_ST = strcat('ST-feature-computation- ',Nom,'.csv');
header = {'Area', 'Motion_Activ','Motion_Field_Mag','Diffused_Int','ST_Gradient_Mag', ...
    'Motion_Activ_Range','Motion_Field_Mag_Range','Diffused_Int_Range','ST_Gradient_Mag_Range', ...
    'label'};

Params.display = false;

for frame_index = 1:4:nb_frames
    if (sum(train_idx(frame_index) == ref_idx) ~= 0)
        % If there is a reference mask.
        match_idx = train_idx(frame_index) == ref_idx;
        fprintf('\nFrame # %d / %d\n', frame_index, nb_frames);

        local_index = mod(frame_index, Params.hist_train_nb_frames);

        if frame_index == 1
            [Glob_Max, Glob_Min, Iref, CDF_Iref, ~, ~, FeatureMap, BackgndImageScaled, DiffusedFrame, ...
                SpatioTemporalWatershedMap, SpatioTemporalGradientMap, SelectedScaleMap, Displacement_Field_Mag] =...
                PreprocessComputeFeaturesSegment(0, 0, 0, 0, frame_index, local_index, ...
                Train_Data, Nom, nb_frames, Params.hist_train_nb_frames, denoise_net, [], Params);
        else
            [Glob_Max, Glob_Min, Iref, CDF_Iref, ~, ~, FeatureMap, BackgndImageScaled, DiffusedFrame, ...
                SpatioTemporalWatershedMap, SpatioTemporalGradientMap, SelectedScaleMap, Displacement_Field_Mag] = ...
                PreprocessComputeFeaturesSegment(Glob_Max, Glob_Min, Iref, CDF_Iref, frame_index, local_index, ...
                Train_Data, Nom, nb_frames, Params.hist_train_nb_frames, denoise_net, BackgndImageScaled, Params);
        end

        Joint_Measure = ...
            ComputeRegionFeatures(frame_index, match_idx, Reference_Data, FeatureMap, Displacement_Field_Mag, ...
            DiffusedFrame, SpatioTemporalGradientMap, SpatioTemporalWatershedMap);

        if frame_index == 1
            writematrix(Joint_Measure, csv_name_ST);
        else
            writematrix(Joint_Measure, csv_name_ST, 'WriteMode', 'append');
        end
    end
end

feature_computation_ST = readtable(strcat('ST-feature-computation-',Nom,'.csv'));
feature_computation_ST.Properties.VariableNames = header;
writetable(feature_computation_ST,csv_name_ST);

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Joint_Measure_ST = ComputeFBFeatures(frame_index, Reference_Data, FeatureMap, ...
    Displacement_Field_Mag, DiffusedFrame, SpatioTemporalGradientMap, SpatioTemporalWatershedMap)

Region_Stats_ST = regionprops(uint16(Reference_Data{frame_index}), FeatureMap, ...
    'MeanIntensity','PixelIdxList','Area');
Region_Stats2_ST = regionprops(uint16(Reference_Data{frame_index}), Displacement_Field_Mag, ...
    'MeanIntensity');
Region_Stats3_ST = regionprops(uint16(Reference_Data{frame_index}), DiffusedFrame, ...
    'MeanIntensity');
Region_Stats4_ST = regionprops(uint16(Reference_Data{frame_index}), SpatioTemporalGradientMap, ...
    'MeanIntensity');

% area_ST = [Region_Stats_ST.Area];
motion_activity_st = [Region_Stats_ST.MeanIntensity];
motion_field_mag_st = [Region_Stats2_ST.MeanIntensity];
diffused_image_intensity = [Region_Stats3_ST.MeanIntensity];
gradient_st = [Region_Stats4_ST.MeanIntensity];

% Joint_Measure_ST_only = [area_ST',motion_activity_ST',motion_field_mag_ST', [0,1]'];
Joint_Measure_ST = [motion_activity_st',motion_field_mag_st', [0,1]']; %, diffused_image_intensity', gradient_st', [0,1]'];

end