function Dynamic_Cell_Features = Quantify_and_Visualize_Cell_Tracks(Cell_Features, sequence_name, image, metadata)
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
    % Visualize track.
    plot3(stack_centroid_x, stack_centroid_y, stack_frame_nb, 'linewidth', 3, 'color', cell_color_map(j,:));
    text(stack_centroid_x(count-1), stack_centroid_y(count-1), stack_frame_nb(count-1), [' ', num2str(j)], ...
        'color', cell_color_map(j,:), 'fontsize' , 11, 'fontweight', 'bold');
    set(gca, 'zdir', 'reverse');
    grid on;
    hold on;
    
    % Compute_Cell_Dynamic_Measures
    % Call function to compute lifetime, MSD, and other motility
    % measures.
    Dynamic_Cell_Features{j} = Compute_Dynamic_Cell_Features(stack_centroid_x, stack_centroid_y, j);
end

% colorbar;
xlabel('x coordinate', 'fontsize', 12);
ylabel('y coordinate', 'fontsize', 12);
zlabel('frame number', 'fontsize', 12);
title(sequence_name, 'fontsize', 14, 'interpreter','none');

% Display frame at the bottom.
colormap(gray);
image_size = size(image);
% plot the image plane using surf.
%Loop over the frames instead nFrames
surf([1 image_size(2)],[1 image_size(1)],repmat(nFrames+2, [2 2]),...
    image,'facecolor','texture');
axis tight;
% axis image;
% view(45,30);

% Write figure to file.
saveas(gcf, ['cell_tracks_', sequence_name, '.png']);
saveas(gcf, ['cell_tracks_', sequence_name, '.fig']);

% Write features to csv text file and display on terminal.
pixel_resolution = metadata.pixel_resolution; %MSC: 0.397;
time_resolution = metadata.time_resolution; %MSC: 20;
fid = fopen(['Dynamic_Features_', sequence_name, '.csv'], 'w');
quantification_string = sprintf('%s\n', 'Cell_Number, Life_Time, Total_Traveled_Distance, Net_Traveled_Distance, Mean_MSD');

for j=1:nbCells
    quantification_string = [quantification_string, sprintf('%d, %f, %f, %f, %f\n', ...
        Dynamic_Cell_Features{j}.Cell_Label, ...
        Dynamic_Cell_Features{j}.Life_Time * time_resolution, ...
        Dynamic_Cell_Features{j}.Total_Traveled_Distance * pixel_resolution, ...
        Dynamic_Cell_Features{j}.Net_Traveled_Distance * pixel_resolution, ...
        Dynamic_Cell_Features{j}.Mean_MSD * pixel_resolution^2)];
end

fprintf(fid, quantification_string);
fclose(fid);

% Display string with all values.
disp(quantification_string);

% Create latex table.
CreateLatexTableFromDataMatrix(Dynamic_Cell_Features, time_resolution, pixel_resolution, sequence_name);

% Create plots of variables.
% Plot MSD(1).
Display_Vector = [];
for j=1:nbCells
    Display_Vector = [Display_Vector, Dynamic_Cell_Features{j}.Mean_MSD * pixel_resolution^2];
end
figure, plot(Display_Vector, 'linewidth', 3);
xlabel('Track ID', 'fontsize', 12);
ylabel('Mean MSD ({\mu m}^2)', 'fontsize', 12);
title(sequence_name, 'fontsize', 14, 'interpreter','none');
grid on;
% Write figure to file.
saveas(gcf, ['Mean_MSD_', sequence_name, '.png']);

% Plot MSF function.
figure, 
for j=1:nbCells
    if Dynamic_Cell_Features{j}.Life_Time > 1
plot([1:length(Dynamic_Cell_Features{j}.MSD_Function)] * time_resolution, ...
    Dynamic_Cell_Features{j}.MSD_Function * pixel_resolution^2, ...
    'linewidth', 2, 'color', cell_color_map(j,:));
    text((length(Dynamic_Cell_Features{j}.MSD_Function))* time_resolution, ...
        Dynamic_Cell_Features{j}.MSD_Function(end)* pixel_resolution^2, num2str(j), ...
        'fontsize', 11, 'color', cell_color_map(j,:));
    hold on;
    end
end
xlabel('Time (min)', 'fontsize', 12);
ylabel('MSD(t) ({\mu m}^2)', 'fontsize', 12);
title(sequence_name, 'fontsize', 14, 'interpreter','none');
grid on;


% Write figure to file.
saveas(gcf, ['MSD_Function_', sequence_name, '.png']);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CreateLatexTableFromDataMatrix(Dynamic_Cell_Features, time_resolution, pixel_resolution, sequence_name)

% Create latex table.
fprintf('\n\nGenerate a LaTex file from data\n\n');

% Some data.
input.data = [];
nbCells = length(Dynamic_Cell_Features);

for j=1:nbCells 
    input.data(j,:) = [Dynamic_Cell_Features{j}.Cell_Label, ...
        Dynamic_Cell_Features{j}.Life_Time * time_resolution, ...
        Dynamic_Cell_Features{j}.Total_Traveled_Distance * pixel_resolution, ...
        Dynamic_Cell_Features{j}.Net_Traveled_Distance * pixel_resolution, ...
        Dynamic_Cell_Features{j}.Mean_MSD * pixel_resolution^2];
end

% we want a complete LaTex document
input.makeCompleteLatexDocument = 1;

% Set column labels (use empty string for no label):
input.tableColLabels = fieldnames(Dynamic_Cell_Features{1});
% Remove label for MST function.
input.tableColLabels = input.tableColLabels(1:end-1);
% Set row labels (use empty string for no label):
% input.tableRowLabels = {'row1','row2','','row4'};

% Set number format/precision.
input.dataFormat = {'%d',2,'%.1f',3}; % three digits precision for first two columns, one digit for the last

% Switch transposing/pivoting your table:
input.transposeTable = 0;

% Determine whether input.dataFormat is applied column or row based:
input.dataFormatMode = 'column'; % use 'column' or 'row'. if not set 'colum' is used

% generate LaTex code
latex = latexTable(input);

% save LaTex code as file
fid=fopen([sequence_name, '_MyLatex.tex'],'w');
[nrows,ncols] = size(latex);
for row = 1:nrows
    fprintf(fid,'%s\n',latex{row,:});
end
fclose(fid);
fprintf('\n... your LaTex code has been saved as ''MyLatex.tex'' in your working directory\n');

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
