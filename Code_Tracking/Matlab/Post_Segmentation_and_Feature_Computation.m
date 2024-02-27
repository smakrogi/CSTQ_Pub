function [Cell_Features, New_Label_Map, New_Intensity_Image] = ...
    Post_Segmentation_and_Feature_Computation(Label_Map, Original_Image, sequence_name, parameters)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% S. Makrogiannis, MIVIC, PEMACS, DESU <smakrogiannis@desu.edu>

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
