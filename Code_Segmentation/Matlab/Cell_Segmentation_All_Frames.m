function [Segmentation_Results_Cell, mean_Dice, mean_Jaccard, seg_measure] = Cell_Segmentation_All_Frames(data_nb, workFolder,...
    dataset_name,Params)
% S. Makrogiannis, MIVIC, PEMACS, DESU <smakrogiannis@desu.edu>

%% Get training and reference data: Cell arrays
% Set filenames and paths.
Nom                  = strcat(dataset_name(1:end-3),dataset_name(end-1:end));
Mask_Name            = [dataset_name,'_Msk_CSTQ',filesep];        
Masks_Folder         = strcat(workFolder,filesep,Mask_Name);
[Train_Data, Reference_Data, Numero_Train, Numero_Ref, ~, nb_frames]  =...
    Get_Some_dataset(workFolder,dataset_name);

fprintf('\nDataset: %s\n', dataset_name);

% Start timer.
tStart = tic;

% Denoising net.
switch Params.noise_filter_type
    case 'autoencoder'
        denoise_net = denoisingNetwork('DnCNN');
    otherwise
        denoise_net = [];
end

% Function to compute features from ST frames.
if Params.training_mode
    Segmentation_Results_Cell = [];
    % Function to compute features from ST frames.
    ForegroundBackgroundFeaturesSTFrames(Train_Data, Reference_Data, Nom, ...
        denoise_net, Numero_Train, Numero_Ref, Params);
    TrainForegroundBackgroundClassifier(Nom, Params);
    ReadAndPlotForegroundBackgroundFeatures(Nom, Params);
    return;
end

% Performance variables
total_Dice            = 0;
total_Jaccard         = 0;
iterations            = zeros(nb_frames,1);
Dice_Res              = zeros(nb_frames,1);
Jaccard_Res           = zeros(nb_frames,1);

mkdir(Masks_Folder);

if Params.display
    % Create figure that displays results.
    figure(1);
    set(gcf, 'Units', 'Normalized', 'OuterPosition', [0.25 0.25 0.65 0.65]);
end


%% Run Segmentation method on all frames of the dataset

% Marker of the reference images for performance evaluation.
marker = 1;

for k = 1:nb_frames
    fprintf('\nFrame # %d / %d\n', k, nb_frames);
    
    % Apply ST Diff Watershed segmentation based on frame modulo.
    if (mod(k, Params.Frame_Modulo)==0)||(k==1)
        
        % First frame, compute cdf, apply intensity transform,
        % spatio-temporal segmentation using diffusion PDE.
        fprintf('S-T diffusion and motion segmentation\n');

       local_index = mod(k, Params.hist_train_nb_frames);
       % frame_range = k:k+hist_estim_interval-1;
       % Local_Train_Data = Train_Data(frame_range);
        
        if k == 1 
            [ST_Contour, Glob_Max, Glob_Min, Iref, CDF_Iref, Itest, Local_Min,...
                ~, BackgndImageScaled, DiffusedFrame]   = ...
                ST_Diffusion_Segmentation_Detection(0, 0, 0, 0, k, local_index, ...
                Train_Data, Nom, nb_frames, Params.hist_train_nb_frames, denoise_net, [], Params);
        else
            [ST_Contour, Glob_Max, Glob_Min, Iref, CDF_Iref, Itest, Local_Min, ...
                ~, ~, DiffusedFrame]   = ...
                ST_Diffusion_Segmentation_Detection(Glob_Max, Glob_Min, Iref, CDF_Iref, k, local_index, ...
                Train_Data, Nom, nb_frames, Params.hist_train_nb_frames, denoise_net, BackgndImageScaled, Params);
        end

        Current_Frame_Scaled = double(DiffusedFrame);

        % Pre-processing, Chan-Vese segmentation, post-processing.
        switch Params.noise_filter_type
            case {'median_filtering_only','median_filtering_and_BM3D','BM3D_only','autoencoder'}
                Params.preproc_ls = true;
            otherwise
                Params.preproc_ls = false;
        end
        fprintf('LS segmentation: %s\n', Params.level_set_type);
        [Seg_Mask,~,Next_Seg_Mask,iter_to_converge] = ...
            LevelSetRefineCellContours(data_nb,Current_Frame_Scaled,ST_Contour,denoise_net,Params);
    else
        % Contrast enhancement.
        Current_Frame_Enhanced = ...
            EnhanceForegroundBackgroundContrast(Train_Data{k}, ...
            Train_Data{k},Train_Data{k},Params);
        
        % Scaling and transformation of previous, current and Next frame
        fprintf('Histogram transformation\n');
        Current_Frame_Scaled = Histogram_Transform(Current_Frame_Enhanced, ...
            Train_Data{k},Train_Data{k},Iref,Itest,Glob_Max, ...
            Glob_Min, Local_Min);
        
        %         % Subtract the background.
        %         Current_Frame_Scaled = abs(Current_Frame_Scaled-BackgndImageScaled);
        
        % Pre-processing, Chan-Vese segmentation, post-processing.
        Params.preproc_ls = true;
        fprintf('LS segmentation: %s\n', Params.level_set_type);
        [Seg_Mask,~,Next_Seg_Mask,iter_to_converge]= ...
            LevelSetRefineCellContours(data_nb,Current_Frame_Scaled,Next_Seg_Mask,denoise_net,Params);
    end
    
    
    %% Post-processing.
    
    % Hole filling.
    Seg_Mask = imfill(Seg_Mask, 8, 'holes');
    Seg_Mask = imresize(Seg_Mask, [size(Train_Data{k},1),size(Train_Data{k},2)],'nearest');

    % Remove small regions.
    areaThreshold = pi*numel(Seg_Mask)/4/10^4;
    areaThreshold = round(areaThreshold);
    Seg_Mask = bwareaopen(Seg_Mask, areaThreshold);
    
    % Cell cluster separation.
    fprintf('Cell cluster separation\n');
    Seg_Mask = Detect_And_Separate_Cell_Clusters(Train_Data{k}, Seg_Mask, Params);
    
%     % Clear image border.
%     Seg_Mask = imclearborder(Seg_Mask, 4);

    % Display mask after post-processing.
    if Params.display && (numel(unique(Seg_Mask))>1)
        figure(1); subplottight(3,4,9);
        imagesc(labeloverlay(Current_Frame_Scaled/max(Current_Frame_Scaled(:)),boundarymask(Seg_Mask), ...
            'Transparency', 0, 'IncludedLabels', 1, 'Colormap', 'hot')); axis image;
        title(['Frame #', num2str(k), '/', num2str(nb_frames), ', Final Mask']);
        drawnow;
    end
    
    
    % Compute DSC and Jaccard Index if reference image exists.
    if (marker<=numel(Numero_Ref))
        % If there is a reference mask.
        if sum( Numero_Ref == Numero_Train(k) ) ~= 0
            match_idx = Numero_Ref == Numero_Train(k);
            Dice_Res(k,1)   = Get_Dice(Seg_Mask, Reference_Data{match_idx});
            Jaccard_Res(k,1)= Get_Jaccard(Seg_Mask, Reference_Data{match_idx});
            total_Dice      = total_Dice + Dice_Res(k);
            total_Jaccard   = total_Jaccard + Jaccard_Res(k,1);
            iterations(k,1) = iter_to_converge;
            fprintf('DSC: %.3f\tJaccard: %.3f\n', Dice_Res(k,1), Jaccard_Res(k,1));
            % Display reference mask.
            if Params.display
                figure(1); subplottight(3,4,10);
                %   imagesc(Train_Data{k}); hold on;
                %   visboundaries(bwboundaries(Reference_Data{marker}));
                imagesc(labeloverlay(Current_Frame_Scaled/max(Current_Frame_Scaled(:)),boundarymask(Reference_Data{match_idx}), ...
                    'Transparency', 0, 'IncludedLabels', 1, 'Colormap', 'hot')); axis image;
                title(['Frame #', num2str(k), '/', num2str(nb_frames),  ...
                    ', Reference Mask']);
                drawnow;
            end
            marker          = marker + 1;
        end
    end
    
    
    % Create label map and write to disk.
    mask_nb = sprintf('%03d', k-1);
    Joint_mask_name = [Masks_Folder, 'mask', mask_nb, '.tif'];
    Seg_Mask = bwlabel(Seg_Mask, 4);
    imwrite(uint16(Seg_Mask), Joint_mask_name);
end

% Display elapsed time.
tElapsed=toc(tStart);
infoString = sprintf('\nElapsed time: %.2f(sec) \n', tElapsed);
fprintf(infoString);


%% Performance evaluation.
% mean DICE of segmentation performance of watershed segmentation of parzen edges of
% filtered diffused frame combined with Chan Vese and temporal linking
mean_Dice  = total_Dice/(marker - 1);
mean_Jaccard = total_Jaccard/(marker - 1);
header     = {'ST_Diff_TCV-DSC' 'ST_Diff_TCV-Jaccard' 'Nb iterations' };
J11        = Dice_Res(:,1);
J21        = Jaccard_Res(:,1);
J31        = iterations;
max_n      = 100;
tr         = @(res)[num2cell(res) ;repmat({[]},max_n-numel(res),1)];
J1         = tr(J11);
J2         = tr(J21);
J3         = tr(J31);
excel_name = strcat('ST_Diff_TCV ',Nom,'.xlsx');
Segmentation_Results_Cell          = [header;[J1 J2 J3]];
writecell(Segmentation_Results_Cell,excel_name);

% Plot results.
performance_string  = ['Dataset: ',Nom,' Mean DSC=',num2str(mean_Dice),' Mean Jaccard=', ...
    num2str(mean_Jaccard)];
fprintf([performance_string, '\n']);
if Params.display
    figure(1); subplottight(3,4,11);
    x          = (0:nb_frames-1);
    plot(x,Dice_Res(:,1),'-rs','MarkerFaceColor','g','MarkerSize',5);hold on;
    plot(x,Jaccard_Res(:,1),'-rs','MarkerFaceColor','b','MarkerSize',5);hold on;
    axis([0 nb_frames-1 0 1]);
    % Make the text of the legend italic and color it brown.
    xlabel('\fontsize{10} Frame number');
    ylabel('\fontsize{10} Measure');
    legend('Dice','Jaccard','Location','southeast');
    grid on; grid minor;
    % Make the text of the legend italic.
    title(performance_string,'color','k','FontAngle','italic','FontSize',10,'Interpreter','none');
    fig_name     = strcat('Plots_Results_',Nom,'.fig');
    saveas(gcf,fig_name);
end

% Calculate SEG measure.
measure_type = 'SEGMeasure ';
data_string = split(dataset_name, '/');
command_string = [fullfile(Params.binary_folder, measure_type), [ ], ...
    fullfile(workFolder, data_string{1}), ' ', data_string{2}, ' 3'];
fprintf([command_string,'\n']);
[~,cmdout] = system(command_string);
fprintf(cmdout);
cmdout = erase(cmdout, newline);
seg_measure_string = extractAfter(cmdout, 'measure: ');
seg_measure = str2double(seg_measure_string);

end