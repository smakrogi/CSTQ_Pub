function [Centroids_X_Y_Coordinates] = Centroid_Trajectories(centroids,Max_Track_Number,Tracks_By_Frame, Cells_Features, Size_Cells, Nb_Frames, Perimeter)

% Compute Centroids_X_Y_Coordinates which will be used to plot the centroid trajectories 
% Initialize the Centroids_X_Y_Coordinates
Centroids_X_Y_Coordinates = zeros(nb_frames, Max_Track_Number, 2);% X and Y values

for i = 1:Nb_Frames
    Centroids_X_Y_Coordinates(i, Tracks_By_Frame{i}, 1) = centroids{i}(:,1); % all X centroids in frame i
    
    Centroids_X_Y_Coordinates(i, Tracks_By_Frame{i}, 2) = centroids{i}(:,2);
end