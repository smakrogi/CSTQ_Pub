function Tracking_Structure = Cell_Tracking_For_Figure(Orig_Folder, Mask_Folder, sequence_name, Glob_Folder)
% Main function for cell tracking.
% syntax: Tracking_Structure = Cell_Tracking_Main(Orig_Folder,
% Mask_Folder, sequence_name);
% Includes the steps of post-segmentation, cell linking using motion field estimation, and creation of cell
% trajectories and acyclic graph structure.
% S. Makrogiannis, MIVIC, PEMACS, DESU <smakrogiannis@desu.edu>

% Add necessary paths with optical flow codes.
% addpath(genpath('./flow_code'));
addpath(genpath('./OpticalFlowCeLiu'));

% Parameter structure.
parameters.threshold_imextendedmin_dist_transf = 5;  % 0.5 for hela2, 5 for sim4
parameters.threshold_cell_area                 = 100;
parameters.postsegmentation                    = false;
frame_number_position                          = 10; %8 for most SIM sequences, 7 for others maybe, 5 for joint our segmentation method, 10 for tracking GT.

%% Read all frames.
[Original_Images, Nb_orig] = Get_Original(Orig_Folder); %the number of masks numel(Bin_Masks);

%% Read all masks.
[Label_Maps, Nb_Masks] = Get_Binary_Masks(Mask_Folder, frame_number_position); % number of masks numel(Bin_Masks);
% AllMasks = zeros([size(Bin_Masks{1}), Nb_Masks]);

% Post segmentation and feature computation.
%----------Label_Maps{1} = imresize(Label_Maps{1}, [size(Original_Images{1},1),size(Original_Images{1},2)],'nearest');
%---------[Cell_Features{1}, Label_Maps{1}]   = Post_Segmentation_and_Feature_Computation(Label_Maps{1}, ...
%---------    Original_Images{1}, sequence_name, parameters);

Cell_Linked_Lists{1} = zeros(max(unique(Label_Maps{1})), 1);
% Cell_Linked_Lists{i} : Number_Cells in frame #i x 1
Max_Likelihood_Scores{1} = zeros(numel(Cell_Linked_Lists{1}), 1);
Cell_Indices{1} = zeros(numel(Cell_Linked_Lists{1}), 1);

for k = 2 : Nb_orig
%     if k==70
%         aaaa= input('For figures:     ');
%         parameters.postsegmentation                    = false;
%     end;
    % Post segmentation and feature computation.
   %------------------ Label_Maps{k} = imresize(Label_Maps{k}, [size(Original_Images{k},1),size(Original_Images{k},2)],'nearest');
   % [Cell_Features{k}, Label_Maps{k}] = Post_Segmentation_and_Feature_Computation(Label_Maps{k}, ...
    %    Original_Images{k}, sequence_name, parameters);
    % Compute and apply displacement field.
    % Warped_Label_Map = Compute_Apply_Displacement_Field(Previous_Frame, Current_Frame, ...
    % Previous_Label_Map, Current_Label_Map, frame_index);
    Warped_Label_Map = Compute_and_Apply_Displacement_Field(Original_Images{k-1}, Original_Images{k}, ...
        Label_Maps{k-1}, Label_Maps{k}, k);
    % Link cells between the label map of time k and the warped label map of time k-1.
    % We use i) area overlap measures or ii) max likelihood rule using
    % features (area, shape, intensity, motion).
    % Link_Cells_Between_Two_Frames.
    %[Cell_Linked_Lists{k}, Cell_Indices{k}, Max_Likelihood_Scores{k}] = ...
    %    Link_Cells_Between_Two_Frames( Original_Images{k}, Original_Images{k-1}, ...
     %   Warped_Label_Map, Label_Maps{k}, Cell_Features);
    
    drawnow();
end

% Create cell trajectories in two stages:
% 1) create a trajectory array structure organized in trajectory ids and cell ids
% containing cell label, frame, parent label and parent frame. Organize
% data in a stack as well (frame #, label #, trajectory #, cell #).
% 2) organize trajectories by finding cell divisions and separating the
% trajectories to create an acyclic graph.
% In the end each trajectory number corresponds to cell id.
%mkdir(Glob_Folder);
%[ Cell_Trajectories, Acyclic_Graph] = Create_Cell_Trajectories( Cell_Linked_Lists, Cell_Indices, sequence_name, Glob_Folder);

% Relabel label maps to match graph and write new maps to image files.

% for k = 1 : Nb_orig
%     number_suffix = sprintf(sprintf('%03d', k-1));
%     output_label_map_filename = [Glob_Folder, 'mask', number_suffix, '.tif'];
%     Output_Label_Map = Assign_Graph_Labels_To_Cells(Label_Maps{k}, ...
%         Cell_Trajectories, Acyclic_Graph, k);
%     imwrite(uint16(Output_Label_Map), output_label_map_filename);
% end

% Pass tracking results to output.
% Tracking_Structure.Linked_Lists = Cell_Linked_Lists;
% Tracking_Structure.Max_Likelihood_Scores = Max_Likelihood_Scores;
% Tracking_Structure.Cell_Trajectories = Cell_Trajectories;
% Tracking_Structure.Cell_Indices = Cell_Indices;
% Tracking_Structure.Acyclic_Graph = Acyclic_Graph;

% Optional step for simple label propagation.
% AllLabels = bwlabeln(AllMasks, 6);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Cell_Features, New_Label_Map, New_Intensity_Image] = ...
    Post_Segmentation_and_Feature_Computation(Label_Map, Original_Image, sequence_name, parameters)

    % Region labeling based on masks.
    if numel(unique(Label_Map))==2
        CC_Structure     = bwconncomp(Label_Map, 4);
        Label_Map    = labelmatrix(CC_Structure);  % is a mapping Create different label to each cell
        Label_Map    = double(Label_Map);
    else
        CC_Structure     = bwconncomp(Label_Map>0, 4);
    end
    % Preprocess_Frame
    if parameters.postsegmentation
        [ New_Intensity_Image, New_Label_Map] = Post_Segmentation(Original_Image, ...
            Label_Map, CC_Structure, sequence_name, parameters.threshold_cell_area, parameters.threshold_imextendedmin_dist_transf);
    else
        New_Intensity_Image = Original_Image;
        New_Label_Map = Label_Map;
    end
    % Compute_Cell_Features
    [ Cell_Features ] = Compute_Cell_Features( Original_Image, New_Label_Map);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Warped_Label_Map = Compute_and_Apply_Displacement_Field(Previous_Frame, Current_Frame, ...
    Previous_Label_Map, Current_Label_Map, frame_index)

% Compute motion models from current and previous frames.
% uv = estimate_flow_interface(Original_Images{k-1}, Original_Images{k}, 'hs');
UV = Call_OF_Ce_Liu(Previous_Frame, Current_Frame);

%     figure(1);
%     subplot(2,2,1); imagesc(Original_Images{frame_index-1}); axis image; colorbar, colormap gray;
%     subplot(2,2,2); imagesc(Original_Images{frame_index}); axis image; colorbar, colormap gray;
%     subplot(2,2,3); imagesc(uint8(flowToColor(UV))); axis image; title('Middlebury color coding');
%     subplot(2,2,4); plotflow(UV); title('Vector plot');

% Apply motion field to original frame and segmented frame.
% First, create meshgrid.
[rows, columns] = size(Previous_Frame);
x = 1:columns;
y = 1:rows;
[XX,YY]=meshgrid(x,y);

% Then use optical flow vectors to create displacement field.
XX_Predicted = XX - UV(:,:,1);
YY_Predicted = YY - UV(:,:,2);

% Apply bilinear interpolation to original image.
%Warped_Original_Image = linint2D2(XX_Predicted, YY_Predicted, Original_Images{k-1});
Warped_Original_Image = interp2(XX,YY, Previous_Frame, ...
    XX_Predicted, YY_Predicted);
i_nan = isnan(Warped_Original_Image);
Warped_Original_Image(i_nan) = 0;

% Apply nearest neighbor interpolation to label image.
Warped_Label_Map = interp2(XX, YY, Previous_Label_Map, ...
    XX_Predicted, YY_Predicted, 'nearest');
i_nan = isnan(Warped_Label_Map);
Warped_Label_Map(i_nan) = 0;

% Display results.
figure;LineColor = 'g';
%set(gcf, 'Units','Normalized','OuterPosition',[0 0 0.8 0.8]);
imagesc(Previous_Frame); axis('image', 'off');
colormap gray; title(['Frame #', num2str(frame_index-1)]); hold on;
[Ox,Oy] = vis_flow(UV(:,:,1),UV(:,:,2)); axis('image', 'off');
pp=input('Next');
figure, imagesc(Current_Frame); axis('image', 'off');
colormap gray; title(['Frame #', num2str(frame_index)]); hold on;
%[Ox,Oy] = vis_flow(UV(:,:,1),UV(:,:,2)); axis('image', 'off');

figure, imagesc(Warped_Original_Image); axis('image', 'off');
colormap gray; title(['Warped frame #', num2str(frame_index-1)]); hold on;
%[Ox,Oy] = vis_flow(UV(:,:,1),UV(:,:,2)); axis('image', 'off');

figure; imagesc(uint8(flowToColor(UV))); axis('image' , 'off');
title('Middlebury color coding');colorbar;
figure, imagesc(Current_Label_Map-Previous_Label_Map), axis('image', 'off');  colormap gray;
title('Reference motion');
figure, imagesc(Warped_Label_Map-Previous_Label_Map), axis('image', 'off');  colormap gray;
title('Computed motion');
PP=input('  KEY TO CLOSE ALL');
close all;

end