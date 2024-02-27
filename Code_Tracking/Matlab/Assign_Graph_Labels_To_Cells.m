function Output_Label_Map = Assign_Graph_Labels_To_Cells(Label_Map, Cell_Trajectories, Acyclic_Graph, frame_number)
% S. Makrogiannis, MIVIC, PEMACS, DESU <smakrogiannis@desu.edu>

% Inputs: label image, cell trajectories,
% acyclic graph before sorting.
cell_labels = unique(Label_Map(:));
n_cells = numel(cell_labels);
Output_Label_Map = zeros(size(Label_Map));

[all_labels, all_frames, non_empty_indices, struct_matrix_size] = ...
    Vectorize_Cell_Trajectory_Struct(Cell_Trajectories);

% For each cell in label image.
for ii=1:n_cells
    cell_label = cell_labels(ii);
    
    if cell_label~=0
        % Find matching tid, cid
        matched_trajectory = ...
            Find_Label_Frame_Match_in_Cell_Trajectories(cell_label, frame_number, ...
            all_labels, all_frames, non_empty_indices, struct_matrix_size);
        % If match is found
        if ~isempty(matched_trajectory)
            % Go to acyclic graph before sorting and get corresponding tid.
            sorted_trajectory_index = find(Acyclic_Graph(:,1) == matched_trajectory);
            
            % Relabel cell in matrix according to row index.
            Output_Label_Map(Label_Map == cell_label) = sorted_trajectory_index;
        end
    end
end

end