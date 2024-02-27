function [ Cell_Features ] = Compute_Cell_Features_Quantification( Original_Image, Label_Map )
%Compute_Cell_Features computes cell feature structure.
%syntax: [ Cell_Features ] = Compute_Cell_Features_Quantification( Original_Image, Label_Map );

%  CC_Structure is equal bwconncomp(Label_Map, 4);
Binary_Mask = Label_Map>0;

% figure(1),subplot(2,1,1);imagesc(Binary_Mask);colormap 'gray',
% titlestring='Binary Mask ';  % cells before removing small areas  ????
% title(titlestring,'color','k');
% axis ('image','off');axis off,
% subplot(2,1,2);imagesc(label2rgb(Label_Map));
% titlestring=['label Map  ' ];
% title(titlestring,'color','k');
% axis ('image','off');axis off,

% Get all the cell features
Cell_Features = regionprops(Label_Map, 'all'); % Struct Nb_Cell x1
numberOfcells = size(Cell_Features, 1);


%%  For Figures
% % % % % Print header line in the command window.
% % % % fprintf(1,'cell #  Mean Area  Perimeter  Centroid  weightedCentroid Solidity Orientation EulerNumber\n');
% % % % % cell measurements
% % % % for k = 1 : numberOfcells
% % % %     % Find the mean of each cell.
% % % %     thiscellPixels = Cell_Features(k).PixelIdxList;  % Get list of pixels in current cell.
% % % %     meancell = mean(Original_Image(thiscellPixels)); % Find mean intensity (in original image!)
% % % %     
% % % %     cellArea = Cell_Features(k).Area;
% % % %     Max_Int = Cell_Features(k).MaxIntensity;
% % % %     cellPerimeter = Cell_Features(k).Perimeter;		% Get perimeter.
% % % %     cellCentroid = Cell_Features(k).Centroid;% Get centroid one by one
% % % %     Weighed_Centroid = Cell_Features(k).WeightedCentroid;
% % % %     cellSolidity=Cell_Features(k).Solidity;
% % % %     cellOrient=Cell_Features(k).Orientation;
% % % %     Euler_Nb = Cell_Features(k).EulerNumber;
% % % %     fprintf(1,'#%2d %17.1f %17.1f %11.1f %8.1f %8.1f %8.1f %8.1f % 8.2f % 8.1f %8.1f\n', k, meancell, cellArea,Max_Int, cellPerimeter, cellCentroid,Weighed_Centroid, cellSolidity, cellOrient,Euler_Nb);
% % % %     
% % % %     
% % % %     % Put the "cell number" labels on the "boundaries" grayscale image.
% % % %     text(cellCentroid(1) + labelShiftX, cellCentroid(2), num2str(k), 'FontSize', 10);
% % % % end

%% Plot label on each cell for Figures 
%  centroids of ALL the cells into 2 arrays:  xpositions and y positions

allcellCentroids = [Cell_Features.Centroid];
centroidsX = allcellCentroids(1:2:end-1);
centroidsY = allcellCentroids(2:2:end);

% figure,
%
% for k = 1 : numberOfcells           % Loop through all cells.Put the "cell number" labels on the "boundaries" grayscale image.
% % % %     text(cellCentroid(1) + labelShiftX, cellCentroid(2), num2str(k), 'FontSize', 10);
% 	text(centroidsX(k) + labelShiftX, centroidsY(k), num2str(k), 'FontSize', 10, 'Fontname', 'Cambria');
% end
%%%%%%%%allcellIntensities = [Cell_Features.MeanIntensity];
allcellAreas = [Cell_Features.Area];
% Get a list of the cells that verify criteria logic

% figure;	% Create a new figure window.
% Maximize the figure window
% set(gcf, 'Units','Normalized','OuterPosition',[0 0 1 1]);


% for p = 1 : numberOfcells           % Loop through all cells.
%     % Find for each cell.
%     thiscellsBoundingBox = Cell_Features(p).BoundingBox;  % Get list of pixels in current cell.
%     % each cell its image
%     subImage = imcrop(Original_Image, thiscellsBoundingBox);
%     % Determine if it's a new (small) or a smalll (large cell) include
%     % the cell clusters from solidity
%     %if Cell_Features(p).Area > 2200
%     % cellType = 'large';
%     %else
%     %cellType = 'new';
%     %end
%     % Display the image with informative caption.
%     figure, colormap 'gray',   %subplot(3, 4, p);
%     imagesc(subImage);axis image; axis off,
%     caption = sprintf('Cell #%d Area = %d pixels', ...
%         p, Cell_Features(p).Area);
%     title(caption);
% end


