function [Processed_Cell_Trajectories] = ...
    Detect_Cell_Events(Cell_Trajectories, cell_trajectory_stack)
% Create cell trajectories and construct an acyclic graph.

% Initialize parameters.
n_trajectories = size(Cell_Trajectories, 1);
new_trajectory_id = n_trajectories;
new_cell_id = 1;
% Trajectory_Lineage_Table = zeros(n_trajectories, 1);

% For each trajectory detect divisions and create new trajectories structure.
for trajectory_id=1:n_trajectories
    % From last frame to first.
    cell_id = 1;
    new_cell_id = 1;
    cell_in_other_trajectory = false;
    trajectory_matches = [];
    parent_label = Cell_Trajectories(trajectory_id, cell_id).parlab;
    
    % Traverse trajectory from bottom to top.
    while parent_label~=0
        frame = Cell_Trajectories(trajectory_id, cell_id).fra;
        label = Cell_Trajectories(trajectory_id, cell_id).lab;
        cell_in_previous_trajectory = false;
        
        % Check if cell is in another trajectory.
        previous_trajectory_matches = trajectory_matches;
        [trajectory_matches, cell_in_other_trajectory] = ...
            Find_Trajectory_Matches(frame, label, ...
            trajectory_id, cell_trajectory_stack);
        
        % Detect division using length of matches and direction of search.
        if ( length(trajectory_matches) > length(previous_trajectory_matches) )
            new_trajectory_id = new_trajectory_id + 1;
            %             Trajectory_Lineage_Table(trajectory_id) = new_trajectory_id;
            new_cell_id = 1;
            % Detect previously processed division.
            if sum(trajectory_id > [trajectory_matches.trajectory_match])~=0
                cell_in_previous_trajectory = true;
            end
        end
        
        % If yes, create new trajectory, and add cell to the trajectory.
        if cell_in_other_trajectory && ...
                ~cell_in_previous_trajectory
            Processed_Cell_Trajectories(new_trajectory_id, new_cell_id).lab = label;
            Processed_Cell_Trajectories(new_trajectory_id, new_cell_id).fra = frame;
            Processed_Cell_Trajectories(new_trajectory_id, new_cell_id).parlab = ...
                Cell_Trajectories(trajectory_id, cell_id).parlab;
            Processed_Cell_Trajectories(new_trajectory_id, new_cell_id).parfra = ...
                Cell_Trajectories(trajectory_id, cell_id).parfra;
            new_cell_id = new_cell_id + 1;
            parent_label = Cell_Trajectories(trajectory_id, cell_id).parlab;
        elseif cell_in_previous_trajectory
            parent_label = 0;
        else
            Processed_Cell_Trajectories(trajectory_id, cell_id).lab = label;
            Processed_Cell_Trajectories(trajectory_id, cell_id).fra = frame;
            Processed_Cell_Trajectories(trajectory_id, cell_id).parlab = ...
                Cell_Trajectories(trajectory_id, cell_id).parlab;
            Processed_Cell_Trajectories(trajectory_id, cell_id).parfra = ...
                Cell_Trajectories(trajectory_id, cell_id).parfra;
            parent_label = Cell_Trajectories(trajectory_id, cell_id).parlab;
        end
        cell_id = cell_id + 1;
    end
    
end

end