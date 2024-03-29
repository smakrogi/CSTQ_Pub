function Plot_X_Y_Trajectories(Cell_Features,  frame_size)  % Birth apoptosis appearrence?
% works? migration all cells from begin to end from begin to end
% cells is a column vector containing all the cells to be plot may be in
% order based on the label number
Col_Cells = Cells(:);
figure, hold on
title('Cell trajectories', 'fontsize', 14)  %or trajectories
xlabel('X '), ylabel('Y ')
axis([0 frame_size(2) 0 frame_size(1)]);
colors =hsv(length(Col_Cells)); % nb labels each frame 
for i = 1:length(Col_Cells)
   
    % Create xy position vector of all cells from start highlight starting one
    X = XY_centroids(:,cells(i),1); Y = XY_centroids(:,cells(i),2);
    Begin_X = X(1:end-1); Begin_Y = Y(1:end-1);%position all trajectories beginning
    Next_X = X(2:end); Next_Y = Y(2:end);% position of all traj not first
    
    %show begin and end of each trajectory   % check color need to be
    % related to the label how?
    plot(Begin_X, Begin_Y, '.', 'color', cstring(mod(label,7)+1)),%'color',colors(i,:));
       %use a colormap HSV to generate a set of colors
plot(Begin_X, Begin_Y, Next_X-Begin_X, Next_Y-Begin_Y);
plot(X,Y,'-','color','b');
    
end

hold off



% frame_nb,nb_cells,XY_centroids: frame_nb ,  nb_of_cell per frame, (X,Y)centroid positions of all cells of frame
