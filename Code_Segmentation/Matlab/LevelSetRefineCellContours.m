function [seg,lev_set,next_seg,iter_to_converge] = ...
    LevelSetRefineCellContours(name_number, InputImage, ST_Prev_Seg, denoise_net, Params)  % I : raw image
% F. Boukari, MIVIC, PEMACS, DESU
% S. Makrogiannis, MIVIC, PEMACS, DESU <smakrogiannis@desu.edu>

lse_bfe_nscales = 1;

% Check if user chooses to skip this step.
if Params.LS_Iter == 0
    seg = ST_Prev_Seg;
    next_seg= seg;   %lev_set<=0;
    next_seg = imresize(next_seg,[size(InputImage,1),size(InputImage,2)]);
    iter_to_converge = Params.LS_Iter;
    lev_set = [];
    pause(0.01);
    return;
end

%% Preprocessing step for level-set segmentation
if Params.preproc_ls
    switch name_number
        case 1    %SIM1
            InputImage = adapthisteq(uint8(InputImage),'NumTiles',[8 8],'ClipLimit',0.025);
        case 2    %SIM2
            InputImage        = imadjust(uint8(InputImage));                                          % for SIM
            InputImage        = gnldf(double(InputImage),20,0.25,'wregion');
        case 3    %SIM3
            InputImage        = imadjust(uint8(InputImage));                                          % for SIM
            H       = fspecial('gaussian', [5 5], 1);  % for MSC
            InputImage       = imfilter(InputImage,H,'replicate');
        case 4    % SIM4
            InputImage        = imadjust(uint8(InputImage));                                          % for SIM
            InputImage = gnldf(double(InputImage),50,0.25,'wregion');  %'hgrad');%'wregion');% nb_iter was 200
        case 5    % SIM5
            InputImage        = imadjust(uint8(InputImage));                                          % for SIM
            InputImage = gnldf(double(InputImage),50,0.25,'wregion');  %'hgrad');%'wregion');
            H=fspecial('gaussian', [5 5], 1);  % for MSC
            InputImage = imfilter(InputImage,H,'replicate');
        case 6    % SIM6
            InputImage        = imadjust(uint8(InputImage));                                          % for SIM
            InputImage = gnldf(double(InputImage),50,0.25,'wregion');
            H=fspecial('gaussian', [5 5], 1);
            InputImage = imfilter(InputImage,H,'replicate');
        case 7    % MSC1
            % De-noising (useful, before computing derivatives).
%             InputImage = medfilt2(InputImage);
%             InputImage=histeq(uint8(InputImage));
            InputImage = adapthisteq(uint8(InputImage),'NumTiles',[4 4],'ClipLimit',0.04);
            InputImage = gnldf(double(InputImage),50,0.25,'wregion'); %'sigmoid');  %'wregion');
        case 8    % MSC2
            % De-noising (useful, before computing derivatives).
%            InputImage = medfilt2(InputImage);
%            InputImage=histeq(uint8(InputImage));
%            InputImage = adapthisteq(uint8(InputImage),'NumTiles',[2 2],'ClipLimit',0.05);
%            InputImage = gnldf(double(InputImage),50,0.25,'wregion'); %'sigmoid');  %'wregion');
%            PSD = 0.1;
%            InputImage = BM3D_Denoising(InputImage,PSD);
        case 9    % Hela1
            %         I=imadjust(I);
%           InputImage = adapthisteq(uint8(InputImage),'NumTiles',[8 8],'ClipLimit',0.025);
        case 10   % Hela2
%            InputImage = adapthisteq(uint8(InputImage),'NumTiles',[8 8],'ClipLimit',0.025);
%            InputImage = gnldf(double(InputImage),50,0.25,'wregion');
        case 11   % GOWT01/1
            %         I        = imadjust(uint8(I));
%            InputImage = adapthisteq(uint8(InputImage),'NumTiles',[8 8],'ClipLimit',0.025);
%            InputImage = gnldf(double(InputImage),50,0.25,'sigmoid');
%             PSD = 0.1;
%             InputImage = BM3D_Denoising(InputImage,PSD);
        case 12   % GOWT01/2
%            InputImage=histeq(uint8(InputImage));
            PSD = 0.1;
            InputImage = BM3D_Denoising(InputImage,PSD);  
        case {13,14} % Fluo-N2DH-SIM+ 01,02
            se_size = 10;
            InputImage = morphological_flattening(uint8(InputImage), se_size);
        case {15,16} % PhC-C2DH-U373 01,02
%             se_size = 10;
%             InputImage = morphological_flattening(uint8(InputImage), se_size);
        case {17,18} % PhC-C2DL-PSC 01,02
%             se_size = 10;
%             InputImage = morphological_flattening(uint8(InputImage), se_size);
        case {19,20} % Fluo-C2DL-Huh7 01,02
%             se_size = 10;
%             InputImage = morphological_flattening(uint8(InputImage), se_size);
        case {21,22} % DIC-C2DH-HeLa 01,02
            mean_intensity = mean(InputImage(:));
            InputImage = abs(InputImage - mean_intensity);
        otherwise   % all other sequences
            switch Params.noise_filter_type
                case 'median_filtering_only'
                    %         fprintf('Median filter denoising\n');
                    %         InputImage = medfilt2(InputImage);
                    %         I =imadjust(I);
                    %         InputImage = morphological_flattening(InputImage);
                    %         InputImage = adapthisteq(uint8(InputImage),'NumTiles',[8 8],'ClipLimit',0.025);
                    %         InputImage = gnldf(double(InputImage),20,0.25,'wregion');
                case {'median_filtering_and_BM3D','BM3D_only'}
                    PSD = 0.1;
                    InputImage = BM3D_Denoising(InputImage,PSD);
                case 'autoencoder'
                    % Denoising autoencoder.
%                     InputImage = denoiseImage(uint8(InputImage),denoise_net);
%                     InputImage = double(InputImage);
            end                  
    end
end

%% Level-set segmentation.
InputImage = double(InputImage);
InputImage = InputImage / max(InputImage(:));
switch Params.level_set_type
    case 'chan_vese'
        [seg,lev_set,iter_to_converge] = ...
            chenvesefile(InputImage,ST_Prev_Seg,'chan',Params);
    case 'lse_bfe'
        Params.LS_Iter = round(Params.LS_Iter/lse_bfe_nscales);
        ST_Prev_Seg_Grid = ST_Prev_Seg;
        for ii=1:lse_bfe_nscales
            downsample_factor = 2^(-lse_bfe_nscales+ii-1); % {2^(-lse_bfe_nscales+ii),2^(-lse_bfe_nscales+ii-1)}
            InputImageGrid = imresize(InputImage, downsample_factor);
            ST_Prev_Seg_Grid = imresize(ST_Prev_Seg_Grid, size(InputImageGrid), 'nearest');
            [ST_Prev_Seg_Grid,lev_set,iter_to_converge] = ...
                lse_bfe_caller(InputImageGrid,ST_Prev_Seg_Grid,Params);
        end
        seg = ST_Prev_Seg_Grid;
end


%% Post-processing.
% switch name_number
%     case {1,2,3,4,5,6}    %SIM1
%         seg      = imfill(seg, 'holes');
%     case {9,10,11,12}    % Hela1
%         seg=imfill(seg, 'holes');
%     otherwise   % all other sequences
%         %         SE=ones(3,3);
%         %         seg=imerode(seg,SE);
% end

next_seg = seg;   %lev_set<=0;
next_seg = imresize(next_seg,[size(InputImage,1),size(InputImage,2)],'nearest');
pause(0.01);
end
