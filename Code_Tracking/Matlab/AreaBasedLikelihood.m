function [matched_cell_label_t_1, max_likelihood_score] = AreaBasedLikelihood(cell_index, Warped_Label_Map_T_1, Label_Map_T)
% Compute overlap between cell i of warped current frame and all cells
% in previous frame.
% S. Makrogiannis, MIVIC, PEMACS, DESU <smakrogiannis@desu.edu>

Binary_Mask_T = Label_Map_T == cell_index;

cell_indices_t_1 = unique(Warped_Label_Map_T_1);

% ToDo: later, check only neighboring cells by SKIZ.
overlap_score = zeros(1, numel(cell_indices_t_1));
for j=2:numel(cell_indices_t_1)
    Binary_Mask_T_1 = Warped_Label_Map_T_1 == cell_indices_t_1(j);
    Overlap_Mask = Binary_Mask_T & Binary_Mask_T_1;
    overlap_score(j) = sum(Overlap_Mask(:));
end

likelihood_score = overlap_score / sum(Binary_Mask_T(:));

[max_likelihood_score, matched_cell_index] = max(likelihood_score);

matched_cell_label_t_1 = cell_indices_t_1(matched_cell_index);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function matched_cell_label = MultiFeatureBasedLikelihood(cell_index, Cell_Features, Label_Map_T, Warped_Label_Map_T)
%
%
%
% end