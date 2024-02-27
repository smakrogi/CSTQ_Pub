function [all_labels, all_frames, non_empty_indices, matrix_size] = Vectorize_Cell_Trajectory_Struct(Processed_Cell_Trajectories)
% syntax: [all_labels, all_frames, non_empty_indices] = Vectorize_Cell_Trajectory_Struct(Processed_Cell_Trajectories)
% Produces vectors of labels and frames and their index instide the cell trajectory structure.
% S. Makrogiannis, MIVIC, PEMACS, DESU <smakrogiannis@desu.edu>

all_labels = {Processed_Cell_Trajectories.lab};
empty_vector = cellfun('isempty', all_labels);
% isemptylabel = @(x) isempty(x.lab);
% empty_vector = arrayfun(isemptylabel, Processed_Cell_Trajectories);
non_empty_vector = 1 - empty_vector;
non_empty_indices = find(non_empty_vector);
all_labels = [Processed_Cell_Trajectories.lab];
all_frames = [Processed_Cell_Trajectories.fra];
matrix_size = size(Processed_Cell_Trajectories);

end