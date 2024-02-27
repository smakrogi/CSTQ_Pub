function Acyclic_Graph_Table = ...
    Create_Acyclic_Graph(Processed_Cell_Trajectories, sequence_name, glob_folder, parameters)
% Create acyclic graph from cell trajectories.
% S. Makrogiannis, MIVIC, PEMACS, DESU <smakrogiannis@desu.edu>

% Initialize variables.
n_processed_trajectories = size(Processed_Cell_Trajectories, 1);
Acyclic_Graph_Table =  zeros(n_processed_trajectories, 4);

[all_labels, all_frames, non_empty_indices, struct_matrix_size] = ...
    Vectorize_Cell_Trajectory_Struct(Processed_Cell_Trajectories);

fprintf('Traversing trajectories %4c', ' ');
for trajectory_id=1:n_processed_trajectories
    progress = ( 100*(trajectory_id/n_processed_trajectories) );
    fprintf('\b\b\b\b%3.0f%%',progress);
    % In this representation:
    % Label is trajectory id.
    % Traverse trajectory from bottom to top.
    cell_id = 0;
    
    % Last frame is the first element of the trajectory.
    last_frame = Processed_Cell_Trajectories(trajectory_id, 1).fra;
    last_label = Processed_Cell_Trajectories(trajectory_id, 1).lab;
    
    if ~isempty(Processed_Cell_Trajectories(trajectory_id, 1).fra)
        % First frame is the last element of the trajectory.
        % parent_label = Processed_Cell_Trajectories(trajectory_id, cell_id).parlab;
        %     parent_label = true;
        %     while (cell_id < size(Processed_Cell_Trajectories(1,:),2)) && ...
        %             ~isempty(parent_label)
        %         cell_id = cell_id + 1;
        %         parent_label = Processed_Cell_Trajectories(trajectory_id, cell_id).parlab;
        %     end
        cell_id = length([Processed_Cell_Trajectories(trajectory_id, :).parlab]);
        first_frame = last_frame - cell_id + 1;
        
        % Parent label is the id trajectory created by division detection.
        % 1. find parent label and frame of trajectory origin using
        % cell_lineage_table(trajectory_id).
        % parent_trajectory_id = Trajectory_Lineage_Table(trajectory_id);
        label_query = Processed_Cell_Trajectories(trajectory_id, cell_id).parlab;
        frame_query = Processed_Cell_Trajectories(trajectory_id, cell_id).parfra;
        if label_query ~= 0
            parent_trajectory_id = ...
                Find_Label_Frame_Match_in_Cell_Trajectories(label_query, frame_query, ...
                all_labels, all_frames, non_empty_indices, struct_matrix_size);
        else
            parent_trajectory_id = 0;
        end
        
        % Acyclic graph.
        Acyclic_Graph_Table(trajectory_id, 1) = trajectory_id;
        Acyclic_Graph_Table(trajectory_id, 2) = first_frame - 1;
        Acyclic_Graph_Table(trajectory_id, 3) = last_frame - 1;
        Acyclic_Graph_Table(trajectory_id, 4) = parent_trajectory_id;
        % Acyclic_Graph_Table(trajectory_id, 5) = last_label;
        % Acyclic_Graph_Table(trajectory_id, 6) = label_query;
    end
end
fprintf('\n');

% Remove zero lines.
index = sum(Acyclic_Graph_Table, 2)~=0;
Acyclic_Graph_Table = Acyclic_Graph_Table(index, :);

% Sort rows by ascending frame order.
Acyclic_Graph_Table = sortrows(Acyclic_Graph_Table, 2);

% Relabel in increasing order starting from 1.
Relabeled_Acyclic_Graph_Table = Relabel_Acyclic_Graph(Acyclic_Graph_Table);

% Write table to file.
% graph_filename = [sequence_name, '_cell_lineage_tree.txt'];
graph_filename = 'res_track.txt';
dlmwrite([glob_folder, graph_filename], Relabeled_Acyclic_Graph_Table, 'delimiter', ' ');

% Create and display tree structure.
if parameters.display
    Plot_Acyclic_Graph(Relabeled_Acyclic_Graph_Table, sequence_name);
end

end