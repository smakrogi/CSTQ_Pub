function Quantification_Structure = Cell_Quantification_Main(work_folder, dataset_name, metadata)
% Main function for cell tracking.
% syntax: Quantification_Structure = Cell_Tracking_Main(Orig_Folder,
% Mask_Folder, sequence_name);
% Includes the steps of post-segmentation, cell linking using motion field estimation, and creation of cell
% trajectories and acyclig graph structure.

% Start timer.
tStart = tic;


% Optional input: parameter structure.
%local labels to start tracking at the tracking result is folder frames with global labels unique label for each cell throughout the whole data sequence
Mask_Name           = [dataset_name, '_Msk_CSTQ']; %  name of folder containing label masks (input)
% Mask_Name           = [dataset_name, '_GT\SEG\'];  % name of folder containing label masks (input)
sequence_name       = strcat(dataset_name(1:end-3),dataset_name(end-1:end));
Mask_Folder         = fullfile(work_folder, filesep, Mask_Name, filesep);
Orig_Folder         = fullfile(work_folder, filesep, dataset_name,filesep);
Glob_Folder         = fullfile(work_folder, filesep, [dataset_name, '_RES', filesep]); % name of folder that will contain label masks (output)
Label_Folder        = fullfile(work_folder, filesep, [dataset_name, '_GT', filesep, 'TRA', filesep]);

% Add necessary paths with optical flow codes.
addpath('../');

% Parameter structure.
% frame_number_position                          = 8; %8 for most SIM sequences, 7 for others maybe, 5 for joint our segmentation method.

%% Read all frames.
[Original_Images, Nb_orig, number_of_digits] = Get_Original_Images(Orig_Folder); %the number of masks numel(Bin_Masks);

%% Read all global masks.
[Label_Maps, Nb_Masks] = Get_Binary_Masks(Glob_Folder); % number of masks numel(Bin_Masks);
% AllMasks = zeros([size(Bin_Masks{1}), Nb_Masks]);

% For each frame in sequence.
Cell_Features = [];
for k = 1 : Nb_orig
    %     if k==70
    %         aaaa= input('For figures:     ');
    %         parameters.postsegmentation                    = false;
    %     end;
    % Post segmentation and feature computation.
    Label_Maps{k} = imresize(Label_Maps{k}, [size(Original_Images{k},1),size(Original_Images{k},2)],'nearest');
    
    % Compute features.
    % Update cell structure with features:
    % centroid location
    % area (eccentricity, etc)
    % shape
    % intensity
    Cell_Features{k} = Compute_Cell_Features_Quantification( Original_Images{k}, Label_Maps{k});
    
  
    drawnow();
end
% Compute cell motility and other advanced measures.
% Plot cell tracks in 2D and 3D.
Dynamic_Cell_Features = Quantify_and_Visualize_Cell_Tracks(Cell_Features, sequence_name, ...
    Original_Images{Nb_orig}, metadata);
Visualize_Cell_Tracks2D(Cell_Features, sequence_name,Original_Images{Nb_orig});

Quantification_Structure = [];

% Display elapsed time.
tElapsed=toc(tStart);     
infoString = sprintf('\nElapsed time: %.2f(sec) \n', tElapsed);
fprintf(infoString);

end

