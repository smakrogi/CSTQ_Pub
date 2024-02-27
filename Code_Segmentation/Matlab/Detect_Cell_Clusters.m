function [Cell_Cluster_Mask, Individual_Cell_Mask] = Detect_Cell_Clusters(Original_Image, Label_Map, thresh_solidity)
% syntax: New_Label_Map = Separate_Cell_Clusters(Original_Image, Label_Map);
% S. Makrogiannis, MIVIC, PEMACS, DESU <smakrogiannis@desu.edu>

%% Algorithm parameters.
% thresh_size = 100;
% thresh_solidity = 0.9;% 0.8926;   %SIM04  thres =0.8926 smallest other .95, 0.9 for Hela2

%% ToDo: use statistical tests to determine threshold for areas.
% Apply thresholding.
% idx = find([Cell_Features.Area] > thresh_size );
% New_Label_Map = ismember(Label_Map, idx);           

%% Generate label from binary map if needed.
if numel(unique(Label_Map))<=2
    CC_Structure = bwconncomp(Label_Map, 4);     
    Label_Map    = labelmatrix(CC_Structure);  
end

%% Small area removal
Binary_Mask = Label_Map > 0;
Cell_Features = regionprops(CC_Structure, 'Area', ...
    'Solidity','PixelIdxList');

%% Estimation of the number of cells in each cluster on original mask Just for figures for thesis
%allcellIntensities = [Cell_Features.MeanIntensity];
% allcellAreas        = [Cell_Features.Area];
allcellSolidity        = [Cell_Features.Solidity];

unique_cell_vector      = allcellSolidity > thresh_solidity;
cell_cluster_vector    = ~unique_cell_vector;
cell_cluster_indices = find(cell_cluster_vector);

% % Create image and show estimated cell number on each cluster
% M_multi         = false(size(Binary_Mask));
% M_multi(cat(1,CC_Structure.PixelIdxList{cell_cluster_vector})) = true;
% figure, imagesc(double(M_multi)), colormap gray;axis image; axis off, hold on

% Expected number of cells in a cluster based on solidity
estimatedCellArea  = mean([Cell_Features(unique_cell_vector).Area]);
estimated_nb_Cells = round([Cell_Features(cell_cluster_vector).Area] / estimatedCellArea);

% Keep cell clusters.
cell_cluster_vector2 = estimated_nb_Cells > 1;
cell_cluster_indices2 = cell_cluster_vector2 ;
cell_cluster_labels = cell_cluster_indices(cell_cluster_indices2);

% Return cell cluster and individual cell masks.
Cell_Cluster_Mask = ismember(Label_Map, cell_cluster_labels);
Individual_Cell_Mask = Binary_Mask - Cell_Cluster_Mask;

end
