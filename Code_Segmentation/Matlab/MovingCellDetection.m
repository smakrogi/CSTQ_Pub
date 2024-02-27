function [SelectedFeatureMap,WatershedRegions,SelectedCurrentFrame,SpatioTemporalGradient, ...
    SelectedScaleMap,Displacement_Field_Mag, UV]=...
    MovingCellDetection(CurrentFrame,PreviousFrame,NextFrame,Params)
% syntax: [SelectedFeatureMap,WatershedRegions,SelectedCurrentFrame,SpatioTemporalGradient]=...
%    MovingObjectDetection(CurrentFrame,PreviousFrame,NextFrame,Params);
% This method uses ST Anisotropic Diffusion, feature detection and
% Watershed Segmentation, to mark the moving areas.
% Sokratis Makrogiannis (smakrogiannis@desu.edu).

% Parameter settings.
Params.internal_diff_iter = 5;  % previous: 5

% Set scale sampling param.
Params.scale_sampling = 'linear'; % options: {'linear','exponential'}
Params.normalize_scales = false;

Params.regional_maxima_detector = 'image_extended_all_scales';
% options:{'image_extended_last_scale','image_extended_all_scales',...
% 'image_extended_separate_scales','choose_last_scale'}

Params.scale_selection_rule = 'second_deriv'; % options: {'max_average', 'second_deriv'}

Params.watershed_input = 'edges'; % {'original','edges'}

% Spatio-temporal diffusion.
% DiffusedFrame is output of motion anisotropic diffusion.
% Integral of diffusion (LoG, DoG).
[DiffusedCurrentFrame,FeatureMaps] = ...
    ComputeScalesAndFeatures(CurrentFrame, PreviousFrame, NextFrame, Params);

% Apply CLGOF to produce the displacement field for F/B separation.
fprintf('CLGOF for F/B separation\n');
[Displacement_Field_Mag, UV] = Compute_and_Apply_Displacement_Field_Mag(PreviousFrame, ...
    CurrentFrame, 1, Params);
% for ii=1:size(FeatureMaps,3)
%     FeatureMaps(:,:,ii) = FeatureMaps(:,:,ii) .* Displacement_Field_Mag;
% end

% Select feature scale.
[SelectedFeatureMap, SelectedScaleMap, selected_scale] = ...
    AutoFeatureScaleSelection(FeatureMaps, Params);

SelectedCurrentFrame = DiffusedCurrentFrame(:,:,selected_scale);


% Display feature space.
if Params.display
    figure(1); subplottight(3,3,3);
    imagesc(imtile(abs(FeatureMaps),'BorderSize',[5, 5])); colorbar; axis('image','off');
    title('Feature Maps in Scale-Space');
end


% Choose input image, use of edges or not, and seed method.
fprintf('Watershed segmentation\n');
fprintf('Mode: %s\n', Params.water_seg_input);

switch Params.water_seg_input
    case 'diff_frame_and_edge_min'
        InputImage = SelectedCurrentFrame;
        Params.watershed_minima = 'edge_map_min'; %{'edge_map_min','feat_map_max'}
    case 'diff_frame_and_feat_map_max'
        InputImage = SelectedCurrentFrame;
        Params.watershed_minima = 'feat_map_max'; %{'edge_map_min','feat_map_max'}
    case 'diff_frame_and_edge_map_and_feat_map'
        InputImage = SelectedCurrentFrame;
        Params.watershed_minima = 'edge_map_and_feat_map'; %{'edge_map_min','feat_map_max'}
    case 'flat_diff_frame_and_edge_map_and_feat_map'
        se_size = 5;
        SelectedCurrentFrame = morphological_flattening(uint8(SelectedCurrentFrame), se_size);
        SelectedCurrentFrame = double(SelectedCurrentFrame);
        InputImage = SelectedCurrentFrame;
        Params.watershed_minima = 'edge_map_and_feat_map'; %{'edge_map_min','feat_map_max'}
    case 'feat_map_and_edge_min'
        InputImage = SelectedFeatureMap;
        Params.watershed_minima = 'edge_map_min'; %{'edge_map_min','feat_map_max'}
    case 'feat_map_and_feat_map_max'
        InputImage = SelectedFeatureMap;
        Params.watershed_minima = 'feat_map_max'; %{'edge_map_min','feat_map_max'}
    case 'feat_map_and_edge_map_and_feat_map'
        InputImage = SelectedFeatureMap;
        Params.watershed_minima = 'edge_map_and_feat_map'; %{'edge_map_min','feat_map_max'}
end



% Watershed-based segmentation of diffused frame.
% (SelectedScaleMap == selected_scale), or (SelectedScaleMap > 0)
[WatershedRegions, SpatioTemporalGradient] = ...
    WatershedSegmentation(InputImage, SelectedScaleMap > 0, ...
    Params.ParzenSigma, 3, Params.ImHMin, Params.watershed_input, Params.watershed_minima);

end
