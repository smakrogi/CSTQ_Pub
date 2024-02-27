function Tracking_Structure = Cell_Tracking_MIVICLAB_Main(workFolder, dataset_name)
% Main function for cell tracking.
% syntax: Tracking_Structure = Cell_Tracking_Main(Orig_Folder,
% Mask_Folder, sequence_name);
% Includes the steps of post-segmentation, cell linking using motion field estimation, and creation of cell
% trajectories and acyclic graph structure.
% S. Makrogiannis, MIVIC, PEMACS, DESU <smakrogiannis@desu.edu>

% Start timer.
tStart = tic;

% Add necessary paths with optical flow codes.
% addpath(genpath('./flow_code'));
% addpath(genpath('./OpticalFlowCeLiu'));

% Parameter structure.
parameters.threshold_imextendedmin_dist_transf = 5;  % 0.5 for hela2, 5 for sim4
parameters.threshold_cell_area                 = 100;
parameters.postsegmentation                    = false;
parameters.display                             = false;  % create figures or not.

% Optional input: parameter structure.
%local labels to start tracking at the tracking result is folder frames with global labels unique label for each cell throughout the whole data sequence
Mask_Name           = [dataset_name, '_Msk_CSTQ']; %  name of folder containing label masks (input)
% Mask_Name           = [dataset_name, '_GT\SEG\'];  % name of folder containing label masks (input)
sequence_name         = strcat(dataset_name(1:end-3),dataset_name(end-1:end));
Mask_Folder         = fullfile(workFolder,filesep,Mask_Name,filesep);
Orig_Folder         = fullfile(workFolder,filesep,dataset_name,filesep);
Glob_Folder         = fullfile(workFolder, filesep, [dataset_name, '_RES',filesep]); % name of folder that will contain label masks (output)

%% Read all frames.
[Original_Images, Nb_orig, number_of_digits] = Get_Original_Images(Orig_Folder); %the number of masks numel(Bin_Masks);

%% Read all masks.
[Label_Maps, ~] = Get_Binary_Masks(Mask_Folder); % number of masks numel(Bin_Masks);
% AllMasks = zeros([size(Bin_Masks{1}), Nb_Masks]);

% Post-segmentation and feature computation.
Label_Maps{1} = imresize(Label_Maps{1}, [size(Original_Images{1},1),size(Original_Images{1},2)],'nearest');
[Cell_Features{1}, Label_Maps{1}]   = Post_Segmentation_and_Feature_Computation(Label_Maps{1}, ...
    Original_Images{1}, sequence_name, parameters);

Cell_Linked_Lists{1} = zeros(max(unique(Label_Maps{1})), 1);
% Cell_Linked_Lists{i} : Number_Cells in frame #i x 1
Max_Likelihood_Scores{1} = zeros(numel(Cell_Linked_Lists{1}), 1);
Cell_Indices{1} = zeros(numel(Cell_Linked_Lists{1}), 1);

% Post segmentation, feature computation, motion field, cell linking.
fprintf('\nDataset: %s\n', dataset_name);
for k = 2 : Nb_orig
    fprintf('\nFrame # %d / %d\n', k, Nb_orig);
    % Post segmentation and feature computation.
    fprintf('Post segmentation and feature computation\n');
    Label_Maps{k} = imresize(Label_Maps{k}, [size(Original_Images{k},1),size(Original_Images{k},2)], 'nearest');
    [Cell_Features{k}, Label_Maps{k}] = Post_Segmentation_and_Feature_Computation(Label_Maps{k}, ...
        Original_Images{k}, sequence_name, parameters);
    
    % Compute and apply displacement field.
    fprintf('Displacement field computation\n');
    Warped_Label_Map = Compute_and_Apply_Displacement_Field(Original_Images{k-1}, Original_Images{k}, ...
        Label_Maps{k-1}, Label_Maps{k}, k, parameters);
    
    % Link cells between the label map of time k and the warped label map of time k-1.
    % We use i) area overlap measures or ii) max likelihood rule using
    % features (area, shape, intensity, motion).
    % Link_Cells_Between_Two_Frames.
    fprintf('Cell linking\n');
     [Cell_Linked_Lists{k}, Cell_Indices{k}, Max_Likelihood_Scores{k}] = ...
        Link_Cells_Between_Two_Frames( Original_Images{k}, Original_Images{k-1}, ...
        Warped_Label_Map, Label_Maps{k}, Cell_Features);
    
    drawnow();
end

% Create cell trajectories in the following stages:
% 1) create a trajectory array structure organized in trajectory ids and cell ids
% containing cell label, frame, parent label and parent frame. Organize
% data in a stack as well (frame #, label #, trajectory #, cell #).
% 2) organize trajectories by finding cell divisions and separating the
% trajectories to create an acyclic graph.
% 3) create an acyclic graph structure that holds the above data.
% In the end each trajectory number corresponds to cell id.
mkdir(Glob_Folder);
fprintf('Creating cell trajectories\n');
[Cell_Trajectories, cell_trajectory_stack] = ...
    Create_Cell_Trajectories(Cell_Linked_Lists, Cell_Indices);

fprintf('Detecting cell events\n');
Processed_Cell_Trajectories = ...
    Detect_Cell_Events(Cell_Trajectories, cell_trajectory_stack);

fprintf('Creating acyclic graph\n');
Acyclic_Graph = ...
    Create_Acyclic_Graph(Processed_Cell_Trajectories, sequence_name, Glob_Folder, parameters);

% Relabel label maps to match graph and write new maps to image files.
fprintf('Relabeling cell maps %4c', ' ');
format_string = ['%0', num2str(number_of_digits), 'd'];
for k = 1 : Nb_orig
    progress = ( 100*(k/Nb_orig) );
    fprintf('\b\b\b\b%3.0f%%',progress);
    number_suffix = sprintf(format_string, k-1);
    output_label_map_filename = [Glob_Folder, 'mask', number_suffix, '.tif'];
    Output_Label_Map = Assign_Graph_Labels_To_Cells(Label_Maps{k}, ...
        Processed_Cell_Trajectories, Acyclic_Graph, k);
    imwrite(uint16(Output_Label_Map), output_label_map_filename);
end
fprintf('\n');

% Pass tracking results to output.
Tracking_Structure.Linked_Lists = Cell_Linked_Lists;
Tracking_Structure.Max_Likelihood_Scores = Max_Likelihood_Scores;
Tracking_Structure.Cell_Trajectories = Processed_Cell_Trajectories;
Tracking_Structure.Cell_Indices = Cell_Indices;
Tracking_Structure.Acyclic_Graph = Acyclic_Graph;

% Optional step for simple label propagation.
% AllLabels = bwlabeln(AllMasks, 6);

% Display elapsed time.
tElapsed=toc(tStart);     
infoString = sprintf('\nElapsed time: %.2f(sec) \n', tElapsed);
fprintf(infoString);

end

