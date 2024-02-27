function [Cell_Trajectories, cell_trajectory_stack] = Create_Cell_Trajectories( Cell_Linked_Lists, Cell_Indices)
% syntax: [Cell_Trajectories, cell_trajectory_stack] = Create_Cell_Trajectories( Cell_Linked_Lists, Cell_Indices);
% Create cell trajectories in two stages:
% 1) create a trajectory array structure organized in trajectory ids and cell ids
% containing cell label, frame, parent label and parent frame. Organize
% data in a stack as well (frame #, label #, trajectory #, cell #).
% 2) organize trajectories by finding cell divisions and separating the
% trajectories to create an acyclic graph.
% In the end each trajectory number corresponds to cell id.
% Use the computed linked lists to create LIFO stacks to hold cell trajectories.
% S. Makrogiannis, MIVIC, PEMACS, DESU <smakrogiannis@desu.edu>

n_lists = length(Cell_Linked_Lists);

% Implement kind of linked lists to store trajectories.
% Each element is a structure with members:
% lab, fra, parlab, parfra, centroid.

% trajectory_id: trajectory identifier (label).
trajectory_id = 0;

% cell_id: cell position in trajectory structure.
cell_id  = 1;

% cell_trajectory_stack: stack of all cells and trajectories in the order 
% in which they are processed.
stack_count = 1;
cell_trajectory_stack = [];

% Starting from the last to the first linked list:
fprintf('Processing cell linked lists %4c', ' ');
for ii=n_lists:-1:1
    progress = ( 100*(n_lists-ii+1) / n_lists );
    fprintf('\b\b\b\b%3.0f%%',progress);
    % Get the index and the stored value and put them in a cell structure
    % holding child and parent relations.
    n_elements = length(Cell_Linked_Lists{ii});
    % For each cell label.
    for jj=1:length(Cell_Indices{ii})
        frame = ii;
        label = Cell_Indices{ii}(jj);
        cell_in_previous_trajectory = false;
        
        % Exclude background.
        if label~=0
            % Search in whole stack to find pair of cell frame and label.
            % If cell is in no previous trajectory, then add cell to trajectory.
            for m=1:size(cell_trajectory_stack, 1)
                if frame == cell_trajectory_stack(m, 1) && ...
                        label == cell_trajectory_stack(m, 2)
                    cell_in_previous_trajectory = true;
                    continue;
                end
            end
            if ~cell_in_previous_trajectory
                % Create new trajectory
                trajectory_id = trajectory_id + 1;
                cell_id = 1;
                
                % Find parent cell.
                parent_label = Cell_Linked_Lists{frame}(label);
                
                % Add cell to current trajectory.
                while parent_label~=0
                    cell_trajectory_stack = [ cell_trajectory_stack; [frame, label, trajectory_id, cell_id]];
                    stack_count = stack_count + 1;
                    % Calculate centroid for current cell.
                    Cell_Trajectories(trajectory_id, cell_id).lab = label;
                    Cell_Trajectories(trajectory_id, cell_id).fra = frame;
                    Cell_Trajectories(trajectory_id, cell_id).parlab = parent_label;
                    Cell_Trajectories(trajectory_id, cell_id).parfra = frame-1;
                    frame = Cell_Trajectories(trajectory_id, cell_id).parfra;
                    label = Cell_Trajectories(trajectory_id, cell_id).parlab;
                    parent_label = Cell_Linked_Lists{frame}(label);
                    cell_id = cell_id + 1;
                end
                
                % To add the top node of trajectory.
                Cell_Trajectories(trajectory_id, cell_id).lab = label;
                Cell_Trajectories(trajectory_id, cell_id).fra = frame;
                Cell_Trajectories(trajectory_id, cell_id).parlab = parent_label;
                Cell_Trajectories(trajectory_id, cell_id).parfra = frame-1;
                cell_trajectory_stack = [cell_trajectory_stack; [frame, label, trajectory_id, cell_id]];
                frame = Cell_Trajectories(trajectory_id, cell_id).parfra;
                label = Cell_Trajectories(trajectory_id, cell_id).parlab;
            end
        end
    end
end
fprintf('\n');

end

