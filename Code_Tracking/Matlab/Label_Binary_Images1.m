%%
clear all; close all;
clc;
%Folder that contains all the masks on desktop for testing;
%workFolder='C:\Users\fboukari\Desktop\Tracking_Masks_Results\';
%workFolder='C:\Users\Public\data_02_19_2015\______BEST MASKS Keep Hela_2Motion_sig20_lambda0.1_TSRatio100\';

%   Binary masks of each dataset is at:   0nb_Msk
%workFolder='C:\Users\Public\data_02_19_2015\Fluo-C2DL-MSC\';
%workFolder='C:\Users\Public\data_02_19_2015\Fluo-N2DH-GOWT1\';
workFolder='C:\Users\Public\data_02_19_2015\Fluo-N2DH-SIM\';
%workFolder='C:\Users\Public\data_02_19_2015\Fluo-N2DL-HeLa\';
% local labels to start tracking at the tracking result is folder frames with global labels unique label for each cell throughout the whole data sequence
%   C:\Users\Public\data_02_19_2015\Fluo-N2DH-SIM\01_Msk
%  toshiba hard drive   F:\datasets\C2DL-MSC
Mask_Name   = '02_Msk\';        %  name of folder containing the binary masks (input)
Label_Name  = '02_Local\';  % name of foler that will contain the lable masks (output) 
Image_Name  = '02\';
Mask_Folder=strcat(workFolder,Mask_Name);
Orig_Folder=strcat(workFolder,Image_Name);
Thresh_Area  = 500;
Glob_Folder =strcat(workFolder,'02_Global\');
%% Call to get all the binary masks in a cell array 

[Bin_Masks,Nb_Masks] = Get_Binary_Masks(Mask_Folder); %the number of masks numel(Bin_Masks);
[originalImage,Nb_orig] = Get_Original(Orig_Folder); %the number of masks numel(Bin_Masks);
AllMasks = zeros([size(Bin_Masks{1}), Nb_Masks]);

%% Read all the masks
% each mask    im = double(Bin_Masks{i})
Nb_Cells_masks = zeros(Nb_Masks);
%dataset_name          = DatasetNames{Data_Nb};   % SIM1(1)   MSC1(7)  GOWT1(11)  Hela1(9)
%Nom                   = strcat(dataset_name(11:end-3),dataset_name(end-1:end));
%for k = 1 :Nb_Masks
for k = 20 :55
   %Create 3D stack image     
   AllMasks(:,:,k) = Bin_Masks{k};
end
AllLabels = bwlabeln(AllMasks, 6);
 for k = 1 :Nb_Masks
    M= Bin_Masks{k};
                 
    labeled_im  = bwconncomp(M, 4);
  %  returns a matrix L, of the same size as labeled_im from matlab help
%   containing labels for the connected components in BW.
% % % % % A = bwconncomp(mask);
% % % % % numPixels = cellfun(@numel,A.PixelIdxList);
% % % % % [A1,...,Am] = cellfun(func,C1,...,Cn) calls the function specified by function handle func and passes elements from cell arrays C1,...,Cn, where n is the number of inputs to function func. Output arrays A1,...,Am, where m is the number of outputs from function func, contain the combined outputs from the function calls. The ith iteration corresponds to the syntax [A1(i),...,Am(i)] = func(C{i},...,Cn{i}). The cellfun function does not perform the calls to function func in a specific order.
% % % % % 
% % % % % [A1,...,Am] = cellfun(func,C1,...,Cn,Name,Value) calls function func with additional options specified by one or more Name,Value pair arguments. Possible values for Name are 'UniformOutput' or 'ErrorHandler'.

numPixels = cellfun(@numel,labeled_im .PixelIdxList);
% Number of pixels in each label  equivalent to area if we want to remove the small
% cells less than thresh area Thresh_Area as pre-tracking step
% for i= 1 : size(numPixels)
%     if (numPixels(i) <= Thresh_Area) 
%         labeled_im.PixelIdxList{i} = 0;
%     end;
% end;

%Nb_Cells_masks(k)=Nb_cells_Mask;    % number of cells in motion image
%  labelmatrix is more memory efficient than bwlabel , 
%using the smallest numeric class necessary for the number of cells
% The functions bwlabel, bwlabeln, and bwconncomp all compute connected components 
   % for binary images. bwconncomp replaces the use of bwlabel and bwlabeln.
   %It uses significantly less memory and is sometimes faster than the other functions.
    
   
  L    = labelmatrix(labeled_im);  % is a mapping Create different label to each cell
  % Note that labelmatrix is more memory efficient than bwlabel , 
%using the smallest numeric class necessary for the number of cells
           % After calling regionprops   Nb_Cells_masks(k)=Nb_cells_Mask;    % number of cells in motion image
   % Reg_label = regionprops(L);   might not be needed        
 
  
% write later imwrite(L,strcat(workFolder,Label_Name,'local',num2str(k-1),'.tiff'));          
   
    
   
   figure,subplot(2,1,1);imagesc(M);colormap 'gray',
   titlestring=['Binary Mask '];  % cells before removing small areas  ????
    title(titlestring,'color','k'); 
    axis ('image','off');axis off,
    subplot(2,1,2);imagesc(label2rgb(L));
    titlestring=['label Mask  ' ];
   title(titlestring,'color','k');
    axis ('image','off');axis off,
    % After calling regionprops Nb_Cells_masks(k)=Nb_cells_Mask;    % number of cells in motion image
 %  save later  saveas(gcf,strcat(workFolder,Label_Name,'SIM4_nb_',num2str(k-1),'.png'), 'png');
  
  coloredLabels = label2rgb (AllLabels(:,:,k), 'hsv', 'k', 'shuffle'); % to have better visual 

%imagesc(coloredLabels);
%
%coloredLabels = label2rgb (AllLabels, 'hsv', 'k', 'shuffle'); 

%subplot(3, 2, 1);
figure, colormap 'gray',imagesc(label2rgb(L));
axis image;axis off, 

% Get all the cell features
cellMeasurements = regionprops(L, 'all');
numberOfcells = size(cellMeasurements, 1);

% bwboundaries() returns a cell array, where each cell contains the row/column coordinates for an object in the image.
% Plot the boundaries of all the cells on the original grayscale image using the results from bwboundaries.
% subplot(3, 3, 6);
figure, colormap 'gray',
Orig=originalImage{k};
imagesc(Orig);
axis image; axis off,
hold on;
boundaries = bwboundaries(M);
numberOfBoundaries = size(boundaries, 1);
for k = 1 : numberOfBoundaries
	thisBoundary = boundaries{k};
	plot(thisBoundary(:,2), thisBoundary(:,1), 'g', 'LineWidth', 0.5);
end
hold off;

textFontSize = 10;	
labelShiftX = -7;	% Used to align the labels in the centers of the cells.
cellECD = zeros(1, numberOfcells);
% Print header line in the command window.
fprintf(1,'cell #      Mean Intensity  Area   Perimeter    Centroid       Diameter\n');
% cell measurements
for k = 1 : numberOfcells           
	% Find the mean of each cell.  

	thiscellPixels = cellMeasurements(k).PixelIdxList;  % Get list of pixels in current cell.
	meancell = mean(Orig(thiscellPixels)); % Find mean intensity (in original image!)
		
	cellArea = cellMeasurements(k).Area;		% Get area.
	cellPerimeter = cellMeasurements(k).Perimeter;		% Get perimeter.
	cellCentroid = cellMeasurements(k).Centroid;		% Get centroid one by one
   	fprintf(1,'#%2d %17.1f %11.1f %8.1f %8.1f %8.1f % 8.1f\n', k, meancell, cellArea, cellPerimeter, cellCentroid, cellECD(k));
	% Put the "cell number" labels on the "boundaries" grayscale image.
	text(cellCentroid(1) + labelShiftX, cellCentroid(2), num2str(k), 'FontSize', 10);
end


%  centroids of ALL the cells into 2 arrays:  xpositions and y positions

allcellCentroids = [cellMeasurements.Centroid];
centroidsX = allcellCentroids(1:2:end-1);
centroidsY = allcellCentroids(2:2:end);

figure,

for k = 1 : numberOfcells           % Loop through all cells.
	text(centroidsX(k) + labelShiftX, centroidsY(k), num2str(k), 'FontSize', 10, 'Fontname', 'Cambria');
end

%%%%%%%%allcellIntensities = [cellMeasurements.MeanIntensity];
allcellAreas = [cellMeasurements.Area];
% Get a list of the cells that verify criteria logic

%%%%%%%%%allowableIntensityIndexes = (allcellIntensities > 150) & (allcellIntensities < 220);
allowableAreaIndexes = allcellAreas > 20; % Take the small cells

%keepIndexes = find(allowableIntensityIndexes & allowableAreaIndexes);
keepIndexes = find( allowableAreaIndexes);
% Extract only those cells that meet our criteria, and
% eliminate those cells that don't meet our criteria.
%  ismember() to do this.  Result will be an image - the same as AllLabels but with only the cells listed in keepIndexes in it.
keepcellsImage = ismember(L, keepIndexes);
% Re-label with only the keep cells kept.
%labelednewImage = bwlabel(keepcellsImage, 8);     % Label each cell so we can make measurements of it

labelednewImage =bwconncomp(keepcellsImage, 4);
% Now we're done.  We have a labeled image of cells that meet our specified criteria.
%subplot(3, 3, 7);
L1    = labelmatrix(labelednewImage);  % mapping Create different label to each cell
figure, colormap 'gray',
imagesc(label2rgb(L1));
axis image;
axis off,

% Plot the centroids in the original image 
% news will have a red cross, large will have a blue X.
%subplot(3, 3, 1);
figure, colormap 'gray',
hold on; 
for p = 1 : numberOfcells           % Loop through all keep cells.
	% Identify if cell #k is a small or big cell
	itsAnew = allcellAreas(p) < 100; % news are small.
	if itsAnew
		% Plot small with a red +.
		plot(centroidsX(p), centroidsY(p), 'r+', 'MarkerSize', 5, 'LineWidth', 1);
	else
		% Plot bog with a blue *.
		plot(centroidsX(p), centroidsY(p), 'b*', 'MarkerSize', 5, 'LineWidth', 1);
	end
end


% Now use the keep cells as a mask on the original image.
% This will let us display the original image in the regions of the keep cells.
maskedImagenew = Orig; 
maskedImagenew(~keepcellsImage) = 0;  % Set all non-keep pixels to zero.
figure, colormap 'gray',  %subplot(3, 3, 8);
imshow(maskedImagenew);
axis image;
title('Only the big from the original image');

% Now let's get the nickels (the larger cell type).
keepIndexes = find(allcellAreas > 2000);  % Take the larger cells
% Note how we use ismember to select the cells that meet our criteria.
smalllmask = ismember(L, keepIndexes);

maskedImagesmalll = Orig; 
maskedImagesmalll(~smalllmask) = 0; 
figure, colormap 'gray',  %subplot(3, 3, 9);
imshow(maskedImagesmalll, []);
axis image;
title('Only the smallls from the original image');

	figure;	% Create a new figure window.
	% Maximize the figure window
	set(gcf, 'Units','Normalized','OuterPosition',[0 0 1 1]);
	for p = 1 : numberOfcells           % Loop through all cells.
		% Find for each cell.
		thiscellsBoundingBox = cellMeasurements(p).BoundingBox;  % Get list of pixels in current cell.
		% each cell its image
		subImage = imcrop(Orig, thiscellsBoundingBox);
		% Determine if it's a new (small) or a smalll (large cell).
		if cellMeasurements(p).Area > 2200
			cellType = 'bigger';
		else
			cellType = 'new';
		end
		% Display the image with informative caption.
		figure, colormap 'gray',   %subplot(3, 4, p);
		imagesc(subImage);
		caption = sprintf('cell #%d is a %s.\nDiameter = %.1f pixels\nArea = %d pixels', ...
			p, cellType, cellECD(p), cellMeasurements(p).Area);
		title(caption);
	end

	
 %-------------------------------Save later  !!!!!!!! 
  %imwrite(AllLabels(:,:,k),strcat(Glob_Folder,'glocal',num2str(k-1),'.tiff'));         
  %saveas(gcf,strcat(Glob_Folder,'nb_',num2str(k-1),'.png'), 'png');
  
end;









