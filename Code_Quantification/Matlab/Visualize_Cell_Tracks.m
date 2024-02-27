function Visualize_Cell_Tracks(Cell_Features, sequence_name)
% input: cell centroid coordinates and frame number organized by cell labels.


nFrames = length(Cell_Features);

% Display in 2D and 3D.
for i=1:nFrames
    nbCells = length(Cell_Features{i});
    % For each cell.
    for j=1:nbCells
        % Get region centroids.
        CentroidX(j,i) = Cell_Features{i}(j).Centroid(1);
        CentroidY(j,i) = Cell_Features{i}(j).Centroid(2);
    end
end

% Plot centroids for each cell and compute dynamic features.
cell_color_map = jet(nbCells);
figure
for j=1:nbCells
    count =1;
    stack_centroid_x = [];
    stack_centroid_y = [];
    stack_frame_nb = [];
    for i=1:nFrames
        if ~isnan(CentroidX(j,i)) && CentroidX(j,i)~=0
            % Get region centroids.
            stack_centroid_x(count) = CentroidX(j,i);
            stack_centroid_y(count) = CentroidY(j,i);
            stack_frame_nb(count) = i;
            count = count + 1;
        end
    end
    % Call functions to compute lifetime, MSD, and other motility
    % measures.
    plot3(stack_centroid_x, stack_centroid_y, stack_frame_nb, 'linewidth', 3, 'color', cell_color_map(j,:));
    set(gca, 'zdir', 'reverse');
    grid on;
    hold on;
    % Compute_Cell_Dynamic_Measures
end
% colorbar;
xlabel('x coordinate', 'fontsize', 12);
ylabel('y coordinate', 'fontsize', 12);
zlabel('frame number', 'fontsize', 12);
title(sequence_name, 'fontsize', 14, 'interpreter','none');

% Plot_X_Y_Trajectories(Cell_Features, XY_centroids,  frame_size);

% Write figure to file.
saveas(gcf, ['cell_tracks_', sequence_name, '.png']);
saveas(gcf, ['cell_tracks_', sequence_name, '.fig']);

