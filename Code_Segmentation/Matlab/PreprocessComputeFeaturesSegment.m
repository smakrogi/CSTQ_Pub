function [Global_Max, Global_Min, Iref, CDF_Iref, Itest, Local_Min, FeatureMap, BackgndImageScaled, DiffusedFrame, ...
    SpatioTemporalWatershedMap, SpatioTemporalGradientMap,SelectedScaleMap,Displacement_Field_Mag, UV] =...
    PreprocessComputeFeaturesSegment(Global_Max, Global_Min, Iref, CDF_Iref, frame_index, train_frame_index, ...
    Training_Data, Nom, nb_all_images, nb_train_images, denoise_net, BackgndImageScaled, Params)

% We find Iref% of histogram of all selected frames at training stage.
if (train_frame_index == 1 && frame_index + nb_train_images <= nb_all_images)
    % Set the percentile to 0.5, or set to empty variable for user input.
    fprintf('Learning Iref\n');
    global_CDF_Iref = 0.995; % 0.5, 0.999
    [Iref, CDF_Iref, Global_Max, Global_Min] =  ...
        Concatenate_Iref_histo_All(Training_Data, Nom, frame_index, frame_index+nb_train_images-1, -1,...
        global_CDF_Iref, Params);
    %     % Estimate Background Image and transform its pixel intensities.
    %     BackgndImage = EstimateBackgroundImage(Training_Data);
    %     [Itest_Background,~,~,Local_Min_Background] = Concatenate_Iref_histo_All(BackgndImage,Nom,1,1,Iref,CDF_Iref, ...
    %         Params);
    %     BackgndImageScaled = Histogram_Transform(BackgndImage,BackgndImage,BackgndImage,Iref,Itest_Background,Global_Max,...
    %         Global_Min,Local_Min_Background);
end


% Run Spatio-Temporal diffusion.
fprintf('Applying Iref\n');
% First frame.
if (frame_index == 1)
    % At testing stage find Itest of 2 frames only first time.
    % Histogram frame 1 and frame 2
    idx_1 = frame_index+2;
    idx_2 = frame_index;
    idx_3 = frame_index+1;
    
    [Training_Data{idx_1},Training_Data{idx_2},Training_Data{idx_3}] = ...
        EnhanceForegroundBackgroundContrast(Training_Data{idx_1},...
        Training_Data{idx_2},Training_Data{idx_3},Params);
    
    [Itest,~,~,Local_Min] = Concatenate_Iref_histo_All(Training_Data,Nom,...
        idx_2,idx_1,Iref,CDF_Iref,Params); % -1:finds Iref%, >=0: finds Itest using Iref%
else
    % Testing stage find Itest of 3 consecutive frames
    % transform 3 frames
    % Intermediate frames.
    if (frame_index~=nb_all_images)
        
        idx_1 = frame_index-1;
        idx_2 = frame_index;
        idx_3 = frame_index+1;
        
        [Training_Data{idx_1},Training_Data{idx_2},Training_Data{idx_3}] = ...
            EnhanceForegroundBackgroundContrast(Training_Data{idx_1},...
            Training_Data{idx_2},Training_Data{idx_3},Params);
        
        [Itest,~,~,Local_Min] = Concatenate_Iref_histo_All(Training_Data,Nom,idx_1,...
            idx_3,Iref,CDF_Iref,Params); % 3 frames
        % Last frame.
    else
        idx_1 = frame_index-1;
        idx_2 = frame_index;
        idx_3 = frame_index-2;
        
        [Training_Data{idx_1},Training_Data{idx_2},Training_Data{idx_3}] = ...
            EnhanceForegroundBackgroundContrast(Training_Data{idx_1},...
            Training_Data{idx_2},Training_Data{idx_3},Params);
        
        [Itest,~,~,Local_Min] = Concatenate_Iref_histo_All(Training_Data,Nom,idx_3,...
            idx_2,Iref,CDF_Iref,Params); %
    end
end

im1            = double(Training_Data{idx_1});
im2            = double(Training_Data{idx_2});
im3            = double(Training_Data{idx_3});


% Scaling and transformation of previous, current and Next frame
fprintf('Histogram transformation\n');
[im1_scaled,im2_scaled,im3_scaled] = Histogram_Transform(im1,im2,im3,Iref,Itest,Global_Max,...
    Global_Min,Local_Min);


% De-noising (useful, before computing derivatives).
switch Params.noise_filter_type
    case 'median_filtering_only'
        fprintf('Median filter denoising\n');
        im1_scaled = medfilt2(im1_scaled);
        im2_scaled = medfilt2(im2_scaled);
        im3_scaled = medfilt2(im3_scaled);
    case 'median_filtering_and_BM3D'
        fprintf('Median and BM3D denoising\n');
        im1_scaled = medfilt2(im1_scaled);
        im2_scaled = medfilt2(im2_scaled);
        im3_scaled = medfilt2(im3_scaled);
        PSD = 0.1;
        im1_scaled = BM3D_Denoising(im1_scaled,PSD);
        im2_scaled = BM3D_Denoising(im2_scaled,PSD);
        im3_scaled = BM3D_Denoising(im3_scaled,PSD);
    case 'BM3D_only'
        fprintf('BM3D denoising\n');
        PSD = 0.1;
        im1_scaled = BM3D_Denoising(im1_scaled, PSD);
        im2_scaled = BM3D_Denoising(im2_scaled, PSD);
        im3_scaled = BM3D_Denoising(im3_scaled, PSD);
    case 'autoencoder'
        % Denoising autoencoder.
        fprintf('Autoencoder denoising\n');
        im1_scaled = denoiseImage(uint8(im1_scaled),denoise_net);
        im2_scaled = denoiseImage(uint8(im2_scaled),denoise_net);
        im3_scaled = denoiseImage(uint8(im3_scaled),denoise_net);
        im1_scaled = double(im1_scaled);
        im2_scaled = double(im2_scaled);
        im3_scaled = double(im3_scaled);
end


% Display results.
if Params.display
    figure(1); subplottight(3,2,1.5);
    imagesc(imtile({im1_scaled,im2_scaled,im3_scaled},...
        'BorderSize',[5, 5],'GridSize',[1,3]))
    axis image; axis off; colorbar % colormap gray;
    title(['Frame #', num2str(frame_index), '/', num2str(nb_all_images), ...
        ', Scaled Input']);
end


% Run the ST_diffusion
fprintf('S-T diffusion and watershed segmentation\n');

[ActivePixelMap,SpatioTemporalWatershedMap,DiffusedFrame,...
    SpatioTemporalGradientMap,SelectedScaleMap,Displacement_Field_Mag, UV] = ...
    MovingCellDetection(im2_scaled,im1_scaled,im3_scaled,Params);


% Choose feature map.
switch Params.motion_activity_measure
    case 'original'
        FeatureMap = im2_scaled;
    case {'diffused','regions_diffused'}
        FeatureMap = DiffusedFrame;
    case {'st_gradient','regions_st_gradient'}
        FeatureMap = SpatioTemporalGradientMap;
    case {'regions_active_pixels','regions_st_laplace',...
            'regions_st_moments','regions_st_hessian',...
            'regions_sp_hessian_tempo_deriv'}
        FeatureMap = ActivePixelMap;
end

end