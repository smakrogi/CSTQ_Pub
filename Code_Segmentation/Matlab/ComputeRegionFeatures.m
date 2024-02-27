function [Joint_Measure, Region_Stats] = ComputeRegionFeatures(frame_index, ref_count, Reference_Data, FeatureMap, ...
    Displacement_Field_Mag, DiffusedFrame, SpatioTemporalGradientMap, SpatioTemporalWatershedMap)
% Compute region features to train F/B classifier.
% S. Makrogiannis, MIVIC, PEMACS, DESU <smakrogiannis@desu.edu>


    Region_Stats{1} = regionprops(SpatioTemporalWatershedMap, FeatureMap, ...
        'MeanIntensity', 'Area', 'MaxIntensity', 'MinIntensity', 'PixelIdxList', 'PixelValues');
    Region_Stats{2} = regionprops(SpatioTemporalWatershedMap, Displacement_Field_Mag, ...
        'MeanIntensity', 'MaxIntensity', 'MinIntensity', 'PixelValues');
    Region_Stats{3} = regionprops(SpatioTemporalWatershedMap, DiffusedFrame, ...
        'MeanIntensity', 'MaxIntensity', 'MinIntensity', 'PixelValues');
    Region_Stats{4} = regionprops(SpatioTemporalWatershedMap, SpatioTemporalGradientMap, ...
        'MeanIntensity', 'MaxIntensity', 'MinIntensity', 'PixelValues');

    % Compute region features.
    area = [Region_Stats{1}.Area];

    motion_activity_st = [Region_Stats{1}.MeanIntensity];
%     motion_activity_st_range = [Region_Stats{1}.MaxIntensity] - [Region_Stats{1}.MinIntensity];
    motion_activity_st_range = ComputePixelValueProperties(Region_Stats{1});

    motion_field_mag_st = [Region_Stats{2}.MeanIntensity];
%     motion_field_mag_st_range = [Region_Stats{2}.MaxIntensity] - [Region_Stats{2}.MinIntensity];
    motion_field_mag_st_range = ComputePixelValueProperties(Region_Stats{2});

    diffused_image_intensity = [Region_Stats{3}.MeanIntensity];
%     diffused_image_intensity_range = [Region_Stats{3}.MaxIntensity] - [Region_Stats{3}.MinIntensity];
    diffused_image_intensity_range = ComputePixelValueProperties(Region_Stats{3});

    gradient_st = [Region_Stats{4}.MeanIntensity];
%     gradient_st_range = [Region_Stats{4}.MaxIntensity] - [Region_Stats{4}.MinIntensity];
    gradient_st_range = ComputePixelValueProperties(Region_Stats{4});

    if ~isempty(Reference_Data)
        % Determine the foreground/background label of each watershed region.
        Region_Stats{5} = regionprops(SpatioTemporalWatershedMap, uint16(Reference_Data{ref_count}), ...
            'MeanIntensity');
        region_label = [Region_Stats{5}.MeanIntensity];
        region_label = round(region_label) - 1;
        Joint_Measure = [area', motion_activity_st', motion_field_mag_st', ...
            diffused_image_intensity', gradient_st', ...
            motion_activity_st_range', motion_field_mag_st_range', ...
            diffused_image_intensity_range', gradient_st_range', region_label'];
    else
        Joint_Measure = [area', motion_activity_st', motion_field_mag_st', ...
            diffused_image_intensity', gradient_st', ...
            motion_activity_st_range', motion_field_mag_st_range', ...
            diffused_image_intensity_range', gradient_st_range'];
    end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function stnd_dev = ComputePixelValueProperties(Region_Struct)

num_regions = numel(Region_Struct);
stnd_dev = zeros(1, num_regions);

for ii=1:num_regions
    stnd_dev(ii) = std(Region_Struct(ii).PixelValues);
end

end