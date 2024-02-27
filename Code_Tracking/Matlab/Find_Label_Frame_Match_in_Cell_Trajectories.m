function matched_trajectory = Find_Label_Frame_Match_in_Cell_Trajectories(label_query, ...
    frame_query, all_labels, all_frames, non_empty_indices, matrix_size)
% syntax: matched_trajectory =
% Find_Label_Frame_Match_in_Cell_Trajectories(label_query, frame_query, Processed_Cell_Trajectories);
% Finds trajectory id match for specific cell label and frame number.
% S. Makrogiannis, MIVIC, PEMACS, DESU <smakrogiannis@desu.edu>

% cellisequallabel = @(x)isequal(x, label_query);
% matched_labels_vector = cellfun(cellisequallabel, all_labels);
% matched_labels = find( matched_labels_vector );
% cellisequalframe = @(x)isequal(x, frame_query);
% matched_frames_vector = cellfun(cellisequalframe, all_frames);
% matched_frames = find( matched_frames_vector );

matched_labels_vector = all_labels == label_query;
matched_frames_vector = all_frames == frame_query;
matched_labels = non_empty_indices(matched_labels_vector);
matched_frames = non_empty_indices(matched_frames_vector);

matched_trajectory = intersect(matched_labels, matched_frames);
[matched_trajectory, matched_cell_id] = ind2sub(matrix_size, matched_trajectory);

end