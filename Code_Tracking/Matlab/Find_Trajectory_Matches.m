function [trajectory_matches, cell_in_previous_trajectory] = ...
    Find_Trajectory_Matches(frame, label, trajectory_id, cell_trajectory_stack)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

n_matches = 0;
trajectory_matches = [];
cell_in_previous_trajectory = false;

for m=1:size(cell_trajectory_stack, 1)
    if frame == cell_trajectory_stack(m, 1) && ...
            label == cell_trajectory_stack(m, 2) && ...
            trajectory_id ~= cell_trajectory_stack(m, 3)
        n_matches = n_matches + 1;
        cell_in_previous_trajectory = true;
        trajectory_matches(n_matches).frame_match = cell_trajectory_stack(m, 1);
        trajectory_matches(n_matches).label_match = cell_trajectory_stack(m, 2);
        trajectory_matches(n_matches).trajectory_match = cell_trajectory_stack(m, 3);
        trajectory_matches(n_matches).cell_id_match = cell_trajectory_stack(m, 4);
    end
end

end

