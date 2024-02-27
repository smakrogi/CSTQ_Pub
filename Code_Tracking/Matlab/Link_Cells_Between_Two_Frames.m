function [ cell_linked_list, cell_indices, max_likelihood_scores ] = Link_Cells_Between_Two_Frames( Frame_T, Frame_T_1, Warped_Label_Map_T_1, Label_Map_T, Cell_Features)
% Warp label map, compute overlap measure and convert to likelihood,
% then link current frame label with previous frame label of max likelihood.
% S. Makrogiannis, MIVIC, PEMACS, DESU <smakrogiannis@desu.edu>

cell_linked_list = [];

% For each cell in time t find the best match from time t-1.
cell_indices = unique(Label_Map_T);
cell_linked_list = zeros(max(cell_indices), 1);
max_likelihood_scores = zeros(max(cell_indices), 1);

for i=2:numel(cell_indices)
    % Case 1:
    % Use motion field only, compute likelihood measure using OF prediction.
    [matched_cell_label_t_1, max_likelihood] = AreaBasedLikelihood(cell_indices(i), Warped_Label_Map_T_1, Label_Map_T);
    
    % Link with best match that is nonzero or greater than a very small value threshold (0.1).
    cell_linked_list(cell_indices(i)) = matched_cell_label_t_1;
    max_likelihood_scores(cell_indices(i)) = max_likelihood;
    
    % Case 2:
    % Use area, shape, intensity, statistical.
    % matched_cell_label = MultiFeatureBasedLikelihood(cell_index, Cell_Features, Label_Map_T, Warped_Label_Map_T);
    
end

end

