function Output_Cell_Mask = Detect_And_Separate_Cell_Clusters(Original_Image, Label_Map, Params)
% syntax: Output_Cell_Mask = Detect_And_Separate_Cell_Clusters(Original_Image, Label_Map, Params);
% S. Makrogiannis, MIVIC, PEMACS, DESU <smakrogiannis@desu.edu>

%% Algorithm parameters.

% Detect the cell clusters based on shape and area characteristics.
[Cell_Cluster_Mask, Individual_Cell_Mask] = Detect_Cell_Clusters(Original_Image, ...
    Label_Map, Params.thresh_solidity);

% Separate the clusters into individual cells using signed distance
% transform and morphological operations.
Separated_Cell_Mask = Separate_Cell_Clusters(Cell_Cluster_Mask, Params.ImHMin_SDT);

% Put the individual and separated cells together.
Output_Cell_Mask = logical(Individual_Cell_Mask) | logical(Separated_Cell_Mask);
end

