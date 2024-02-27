function [ New_Intensity_Image, New_Label_Map] = ...
    Post_Segmentation( Intensity_Image, Label_Map, CC_Structure, Nom, Thresh_Size, Thresh_Imextendedmin_Dist_Transf)
% Post Segmentation: Non-lin filter small areas removal and cell separation
%   [ New_Intensity_Image, New_Region_Mask] = Post_Segmentation( Intensity_Image, Region_Mask )Detailed explanation goes here
% Input:
%   Intensity_Image:  Original image
%   Region_Mask:      Segmented image mask
%   Nom:              Dataset name
%   Thresh_Size:  Minimal cell area Thresholfd value for the size of the cells to be considered as a cell.
%   Thresh_Imextendedmin_Dist_Transf imextendedmin(Dist_Transf, H) thresh for the extended-minima transform, which is the regional minima of the
%   H-minima transform:   5 for Sim4
%                         1 for hela2
%   May add another input parameter  Thresh_solidity
% Output:
%   New_Intensity_Image:  Enhanced image [row col] after non linear filter.Noise removal using non-linear filtering???
%   New_Region_Mask:   Mask regions that are considered as cells.
%                      Cell clusters are separated into different region Maks.
% F. Boukari, MIVIC, PEMACS, DESU
% S. Makrogiannis, MIVIC, PEMACS, DESU <smakrogiannis@desu.edu>

%% Image enhancement using a non-linear filter
% New_Intensity_Image  = gnldf(double(Intensity_Image), 10, 0.25, 'wregion');  % n=20 before.
% %     H       = fspecial('gaussian', [5 5], 1);  % for MSC
% %     New_Intensity_Image       = imfilter(Intensity_Image,H,'replicate');
% %     New_Intensity_Image       = histeq(Intensity_Image);

New_Intensity_Image = Intensity_Image;
Original_Image= New_Intensity_Image;
%% Small area removal
%CC_Structure  = bwconncomp(Region_Mask, 4);
% is a mapping Create different label to each cell
% Label_Map    = labelmatrix(CC_Structure);
Binary_Mask = Label_Map>0;

% Number of pixels in each label  equivalent to area if we want to remove the small
% cells less than thresh area Thresh_Area as pre-tracking step
numPixels = cellfun(@numel, CC_Structure.PixelIdxList);
% % % % % % % %      for i= 1 : size(numPixels)
% % % % % % % %          if (numPixels(i) <= Thresh_Size)
% % % % % % % %              CC_Structure.PixelIdxList{i} = 0;
% % % % % % % %          end;
% % % % % % % %      end;
% After calling regionprops Nb_Cells_masks(k)=Nb_cells_Mask;    % number of cells in motion image
%  save later  saveas(gcf,strcat(workFolder,Label_Name,'SIM4_nb_',num2str(k-1),'.png'), 'png');
% Get the cell area and solidity to estimate the number of cells

Cell_Features        = regionprops(CC_Structure, 'Area', 'Perimeter','Orientation','Solidity', 'Centroid','PixelIdxList','BoundingBox');

% Use statistical tests to determine threshold for areas.

% Apply thresholding.
idx = find([Cell_Features.Area] > Thresh_Size );
New_Label_Map        = ismember(Label_Map, idx);           %  labelmatrix
if numel(unique(New_Label_Map))==2
    CC_Structure     =bwconncomp(Label_Map, 4); %    bwconncomp(New_Label_Map, 4);
    New_Label_Map    = labelmatrix(CC_Structure);  % Mapping Create different label to each cell
end
figure,subplot(3,1,1);imagesc(Binary_Mask);colormap 'gray',
titlestring          = ['Binary Mask before removing small regions ',Nom];  % cells before removing small areas
title(titlestring,'color','k');
axis ('image','off');
subplot(3,1,2);imagesc(label2rgb(Label_Map));
titlestring          = ['label map  ',Nom ];
title(titlestring,'color','k');
axis ('image','off');
subplot(3,1,3);imagesc(New_Label_Map);
titlestring          = ['Mask After small regions removal ', Nom ];
title(titlestring,'color','k');
axis ('image','off');

figure,imagesc(label2rgb(Label_Map, 'prism','k', 'shuffle'));title(titlestring,'color','k');axis image; axis off,

%% Estimation of the number of cells in each cluster on original mask Just for figures for thesis
% Evaluation or estimation of the number of colided cells in each cluster
% based on the estimated mean area size of a unique cell
%'Solidity' — Scalar specifying the proportion of the pixels in the convex hull that are also in the region.
% Computed as Area/ConvexArea. This property is supported only for 2-D input label matrices.
figure, plot(sort([Cell_Features.Solidity]),'-b.');
Thresh_solidity = 0.97;% 0.8926;   %SIM04  thres =0.8926 smallest other .95, 0.9 for Hela2
UniqueCell      = [Cell_Features.Solidity]>Thresh_solidity;
Cell_Cluster    = ~UniqueCell;

% Create image and show estimated cell number on each cluster
M_empty         = false(size(Binary_Mask));
M_multi         = false(size(Binary_Mask));
%[M_empty,M_multi] = deal(false(size(Binary_Mask)));
M_multi(cat(1,CC_Structure.PixelIdxList{Cell_Cluster})) = true;
figure, imagesc(double(M_multi)), colormap gray;axis image; axis off, hold on

% Expected number of cells in a cluster based on solidity
estimatedCellArea  = mean([Cell_Features(UniqueCell).Area]);
estimated_nb_Cells = round([Cell_Features(Cell_Cluster).Area] / estimatedCellArea);
multiCentroids     = cat(1,Cell_Features(Cell_Cluster).Centroid);
if ~isempty(multiCentroids)
    text(multiCentroids(:,1),multiCentroids(:,2), num2str(estimated_nb_Cells'), 'Color','g','FontWeight','bold', 'FontSize', 9)
end
hold off;
numberOfcells      = size(Cell_Features, 1);
figure,
set(gcf, 'Units','Normalized','OuterPosition',[0 0 .8 .8]);
colormap 'gray',
imagesc(Intensity_Image);
axis image; axis off,
hold on;
boundaries         = bwboundaries(Binary_Mask);
numberOfBoundaries = size(boundaries, 1);
for k = 1 :20: numberOfBoundaries
    thisBoundary   = boundaries{k};
    plot(thisBoundary(:,2), thisBoundary(:,1), 'g', 'LineWidth', 0.5);
end
hold off;
%%
textFontSize = 7;
labelShiftX = -7;	% Used to align the labels in the centers of the cells.
cellECD     = zeros(1, numberOfcells);
% Print header line in the command window.
fprintf(1,'cell #      Mean Intensity  Area  Perimeter    Centroid   Solidity Orientation\n');
% cell measurements
for k = 1 : numberOfcells
    % Find the mean of each cell.
    thiscellPixels = Cell_Features(k).PixelIdxList;  % Get list of pixels in current cell.
    meancell       = mean(New_Intensity_Image(thiscellPixels)); % Find mean intensity (in original image!)
    
    cellArea       = Cell_Features(k).Area;		% Get area.
    cellPerimeter  = Cell_Features(k).Perimeter;		% Get perimeter.
    cellCentroid   = Cell_Features(k).Centroid;		% Get centroid one by one
    cellSolidity   = Cell_Features(k).Solidity;
    cellOrient     = Cell_Features(k).Orientation;
    fprintf(1,'#%2d %17.1f %11.1f %8.1f %8.1f %8.1f % 8.2f % 8.1f\n', k, meancell, cellArea, cellPerimeter, cellCentroid, cellSolidity, cellOrient);
    
    
    % Put the "cell number" labels on the "boundaries" grayscale image.
    text(cellCentroid(1) + labelShiftX, cellCentroid(2), num2str(k),'color','yellow', 'FontSize', 7,'Fontname', 'Cambria','FontWeight','bold','FontAngle','italic');
end
%  centroids of ALL the cells into 2 arrays:  xpositions and y positions

allcellCentroids = [Cell_Features.Centroid];
centroidsX       = allcellCentroids(1:2:end-1);
centroidsY       = allcellCentroids(2:2:end);

%  figure,
% 
%  for k = 1 : numberOfcells           % Loop through all cells.
%  	text(centroidsX(k) + labelShiftX, centroidsY(k), num2str(k), 'FontSize', 10, 'Fontname', 'Cambria');
%  end

%allcellIntensities = [Cell_Features.MeanIntensity];
allcellAreas        = [Cell_Features.Area];
% Get a list of the cells that verify criteria logic

%%%%%%%%%allowableIntensityIndexes = (allcellIntensities > 150) & (allcellIntensities < 220);
allowableAreaIndexes = allcellAreas > 2; % Removes the small cells for now we remove only size=2 to almost keep all

%keepIndexes = find(allowableIntensityIndexes & allowableAreaIndexes);
keepIndexes = find( allowableAreaIndexes);
% Extract only those cells that meet our criteria, and
% eliminate those cells that don't meet our criteria.
%  ismember() to do this.  Result will be an image - the same as AllLabels but with only the cells listed in keepIndexes in it.
keepcellsImage = ismember(Label_Map, keepIndexes);
% Re-label with only the keep cells kept.
%labelednewImage = bwlabel(keepcellsImage, 8);     % Label each cell so we can make measurements of it

labelednewImage =bwconncomp(keepcellsImage, 4);
% We have a labeled image of cells that meet our specified criteria.
%subplot(3, 3, 7);
L1    = labelmatrix(labelednewImage);  % mapping Create different label to each cell
figure, %colormap 'gray',
imagesc(label2rgb(L1));
axis image;
axis off,

% Plot the centroids in the original image
% news will have a red cross, large will have a blue X.
%subplot(3, 3, 1);
% figure, colormap 'gray',
% hold on;
% for p = 1 : numberOfcells           % Loop through all keep cells.
%     % Identify if cell #k is a small or big cell
%     itsSmall = allcellAreas(p) < 20; %  small.
%     if itsSmall
%         % Plot small with a red +.
%         plot(centroidsX(p), centroidsY(p), 'r+', 'MarkerSize', 5, 'LineWidth', 1);
%     else
%         % Plot bog with a blue *.
%         plot(centroidsX(p), centroidsY(p), 'b*', 'MarkerSize', 5, 'LineWidth', 1);
%     end
% end


% Now use the keep cells as a mask on the original image.
% This will let us display the original image in the regions of the keep cells.
maskedImagenew = Original_Image;
maskedImagenew(~keepcellsImage) = 0;  % Set all non-keep pixels to zero.
figure, colormap 'gray',  %subplot(3, 3, 8);
imagesc(maskedImagenew);
axis image; axis off,
title('After small regions removal');

% % Now let's get the larger cell type for cell separation
 keepIndexes = find(allcellAreas > 500);  % Take the larger cells
% % Note how we use ismember to select the cells that meet our criteria.
 smalllmask = ismember(L1, keepIndexes);
%
 maskedImagesmalll = Original_Image;
 maskedImagesmalll(~smalllmask) = 0;
 figure,   %subplot(3, 3, 9);
 imshow(maskedImagesmalll, []);
 axis image;
 title('Only the smallls from the original image');
individual_Cells=true;false;
if individual_Cells
    figure;	% Create a new figure window.
    % Maximize the figure window
    %set(gcf, 'Units','Normalized','OuterPosition',[0 0 1 1]);
    for p = 1 : 20:numberOfcells           % Loop through all cells.
        % Find for each cell.
        thiscellsBoundingBox = Cell_Features(p).BoundingBox;  % Get list of pixels in current cell.
        % each cell its image
        subImage = imcrop(Original_Image, thiscellsBoundingBox);
        % Determine if it's a new (small) or a smalll (large cell) include
        % the cell clusters from solidity
        %if Cell_Features(p).Area > 2200
        cellType = 'large';
        %else
        %cellType = 'new';
        %end
        % Display the image with informative caption.
        figure, %colormap 'gray',   %subplot(3, 4, p);
        imagesc(subImage);axis image; axis off,
        %caption = sprintf('cell #%d is a %s.\nDiameter = %.1f pixels\nArea = %d pixels',p, cellType, cellECD(p), Cell_Features(p).Area);
        caption=sprintf('Cell #%2d Area %11.1f Perimeter %8.1f\n Solidity %8.2f  Orientation%8.1f \n', p, Cell_Features(p).Area,...
            Cell_Features(p).Perimeter, Cell_Features(p).Solidity,Cell_Features(p).Orientation);
    
        
        title(caption);
    end
end

%% Cell cluster separation  on the New_Region_Mask after removal of small regions Region_Mask or  Binary_Mask
Dist_Transf = bwdist(New_Label_Map)-bwdist(~New_Label_Map);
figure, imagesc(Dist_Transf);
titlestring='Distance transf of mask  ';
title(titlestring,'color','k');axis image; axis off,
Label_Dist_Transf = watershed(Dist_Transf);

figure, imagesc(label2rgb(Label_Dist_Transf))
titlestring='watershed Distance';
title(titlestring,'color','k');
axis image; axis off,

New_Label_Map_Separated = New_Label_Map;
New_Label_Map_Separated(Label_Dist_Transf == 0) = 0;
figure, imshowpair(Intensity_Image, Label_Dist_Transf == 0,'falsecolor');axis image; axis off,
titlestring='Watershed ridges superposed on the original image';
title(titlestring,'color','k');axis image; axis off,
figure, imagesc(New_Label_Map_Separated);titlestring='Label Map showing oversegmented cell separation';
title(titlestring,'color','k','FontSize', 12, 'Fontname', 'Cambria');axis image; axis off,
L3 =bwconncomp(New_Label_Map_Separated, 4);
L4    = labelmatrix(L3);  % mapping Create different label to each cell
figure,
imagesc(label2rgb(L4, 'prism','k', 'shuffle'));titlestring='separated1';
titlestring='Final result of cell separation';
title(titlestring,'color','k','FontSize', 12, 'Fontname', 'Cambria');axis image; axis off,
figure,
imagesc(label2rgb(L4));titlestring='separated1';
titlestring='new after watershed dist transform';
title(titlestring,'color','k','FontSize', 12, 'Fontname', 'Cambria');axis image; axis off,Thresh_Imextendedmin_Dist_Transf=0.5;
Imextendedmin_Dist_Transf = imextendedmin(Dist_Transf,Thresh_Imextendedmin_Dist_Transf);%5 for Sim4  %1  0.75  0.5 better separation for hela2
% computes the extended-minima transform, which is the regional minima of the H-minima transform. Regional minima are connected components of pixels with a constant intensity value, and whose external boundary pixels all have a higher value.
% h is a nonnegative scalar. By default, imextendedmin uses 8-connected neighborhoods for 2-D images and 26-connected neighborhoods for 3-D images.

figure, imshowpair(New_Label_Map,Imextendedmin_Dist_Transf,'falsecolor');
titlestring='H-minima Transform';
title(titlestring,'color','k');axis image; axis off,

figure, imshowpair(New_Label_Map,Imextendedmin_Dist_Transf);
titlestring='mask extended-minima transform';
title(titlestring,'color','k','FontSize', 12, 'Fontname', 'Cambria');axis image; axis off,  % colormap gray;
Dist_Transf2 = imimposemin(Dist_Transf, Imextendedmin_Dist_Transf);

%We modify the distance transform using morphological reconstruction so it only has regional minima
% wherever Imextendedmin_Dist_Transf is nonzero we impose the minima.
Label_Dist_Transf2 = watershed(Dist_Transf2);
Label_Dist_Transf2_Separated = New_Label_Map;
Label_Dist_Transf2_Separated(Label_Dist_Transf2 == 0) = 0;

L3 =bwconncomp(Label_Dist_Transf2_Separated, 4);
L4    = labelmatrix(L3);  % mapping Create different label to each cell
figure,
imagesc(label2rgb(L4, 'prism','k', 'shuffle'));titlestring='separated transf2 min imposed'; titlestring='new after watershed dist transform';
title(titlestring,'color','k');axis image; axis off,

figure, imagesc(Label_Dist_Transf2_Separated);titlestring='watershed of dist transform of minima imposed';
title(titlestring,'color','k');
figure, imagesc(Label_Dist_Transf2_Separated);titlestring='watershed of dist transform of minima imposed';
title(titlestring,'color','k');axis image; axis off,
figure, imshowpair(Intensity_Image, Label_Dist_Transf2 == 0,'falsecolor');titlestring='intensuty im and watershed of minima imposed';
title(titlestring,'color','k');
drawnow();axis image; axis off,
figure,imagesc(label2rgb(Label_Map, 'prism','k', 'shuffle'));title(titlestring,'color','k');axis image; axis off,
%axis([236 738 96 572]);
% Return the last binary mask with the new separated cells
New_Label_Map = Label_Dist_Transf2_Separated;

end

