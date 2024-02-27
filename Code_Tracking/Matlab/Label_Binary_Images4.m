%%
% clear all; close all;
close all;
clc;
%Folder that contains all the masks on desktop for testing;
%workFolder='C:\Users\fboukari\Desktop\Tracking_Masks_Results\';
%workFolder='C:\Users\Public\data_02_19_2015\______BEST MASKS Keep Hela_2Motion_sig20_lambda0.1_TSRatio100\';
%Binary masks of each dataset is at:   0nb_Msk
%workFolder='C:\Users\Public\data_02_19_2015\Fluo-C2DL-MSC\';
%workFolder='C:\Users\Public\data_02_19_2015\Fluo-N2DH-GOWT1\';
%workFolder='C:\Users\Public\data_02_19_2015\Fluo-N2DH-SIM\';
 workFolder='C:\Users\Public\data_02_19_2015\Fluo-N2DL-HeLa\';
%local labels to start tracking at the tracking result is folder frames with global labels unique label for each cell throughout the whole data sequence
%C:\Users\Public\data_02_19_2015\Fluo-N2DH-SIM\01_Msk
%toshiba hard drive   F:\datasets\C2DL-MSC
Mask_Name   = '02_Msk\';        %  name of folder containing the binary masks (input)
Label_Name  = '02_Local\';  % name of foler that will contain the lable masks (output)
Image_Name  = '02\';
Mask_Folder=strcat(workFolder,Mask_Name);
Orig_Folder=strcat(workFolder,Image_Name);
Thresh_Area  = 500;
Glob_Folder =strcat(workFolder,'02_Global\');
display_each_cell = false;

%% Call to get all the binary masks in a cell array

[Bin_Masks,Nb_Masks] = Get_Binary_Masks(Mask_Folder, 7); %the number of masks numel(Bin_Masks);
[originalImage,Nb_orig] = Get_Original(Orig_Folder); %the number of masks numel(Bin_Masks);
AllMasks = zeros([size(Bin_Masks{1}), Nb_Masks]);

%% Read all the masks
% each mask    im = double(Bin_Masks{i})
Nb_Cells_masks = zeros(Nb_Masks);
%dataset_name          = DatasetNames{Data_Nb};   % SIM1(1)   MSC1(7)  GOWT1(11)  Hela1(9)
%Nom                   = strcat(dataset_name(11:end-3),dataset_name(end-1:end));
for k = 1 :Nb_Masks
    %for k = 20 :55
    %Create 3D stack image
    AllMasks(:,:,k) = Bin_Masks{k};
    if k==73   % if we want to run for specific frame hela02  use if k == 73  SIM 4 use k= 
% % % % %         %%%%%
% % % % %         Bin_Mask =Bin_Masks{k};  % imread(Im_Name);
% % % % % L = watershed(Bin_Mask);
% % % % % Lrgb = label2rgb(L);
% % % % % figure, imagesc(Lrgb)
% % % % % figure, imagesc(imfuse(Bin_Mask,Lrgb))
% % % % % axis([10 175 15 155])
% % % % % Bin_Mask2 = ~bwareaopen(~Bin_Mask, 10);
% % % % % figure, imagesc(Bin_Mask2)
% % % % % Dist_Transf = -bwdist(~Bin_Mask);
% % % % % figure, imagesc(Dist_Transf,[])
% % % % % LDist_Transf = watershed(Dist_Transf);
% % % % % figure, imagesc(label2rgb(LDist_Transf))
% % % % % Bin_Mask2 = Bin_Mask;
% % % % % Bin_Mask2(LDist_Transf == 0) = 0;
% % % % % figure, imagesc(Bin_Mask2)
% % % % % mask = imextendedmin(Dist_Transf,2);
% % % % % figure, imagescpair(Bin_Mask,mask,'falsecolor')
% % % % % imshowpair(Bin_Mask,mask,'montage');
% % % % % Dist_Transf2 = imimposemin(Dist_Transf,mask);
% % % % % LDist_Transf2 = watershed(Dist_Transf2);
% % % % % Bin_Mask3 = Bin_Mask;
% % % % % Bin_Mask3(LDist_Transf2 == 0) = 0;
% % % % % figure, imagesc(Bin_Mask3)
% % % % % F=imread(img);
% % % % % 
% % % % % F=im2double(F);
% % % % % 
% % % % % %Converting RGB image to Intensity Image
% % % % % r=F(:,:,1);
% % % % % g=F(:,:,2);
% % % % % b=F(:,:,3);
% % % % % I=(r+g+b)/3;
% % % % % imagesc(I);
% % % % % 
% % % % % %Applying Gradient
% % % % % hy = fspecial('sobel');
% % % % % hx = hy';
% % % % % Iy = imfilter(double(I), hy, 'replicate');
% % % % % Ix = imfilter(double(I), hx, 'replicate');
% % % % % gradmag = sqrt(Ix.^2 + Iy.^2);
% % % % % figure, imagesc(gradmag,[]), title('Gradient magnitude (gradmag)');
% % % % % 
% % % % % L = watershed(gradmag);
% % % % % Lrgb = label2rgb(L);
% % % % % figure, imagesc(Lrgb), title('Watershed transform of gradient magnitude (Lrgb)');
% % % % % 
% % % % % se = strel('disk',20);
% % % % % Io = imopen(I, se);
% % % % % figure, imagesc(Io), title('Opening (Io)');
% % % % % Ie = imerode(I, se);
% % % % % Iobr = imreconstruct(Ie, I);
% % % % % figure, imagesc(Iobr), title('Opening-by-reconstruction (Iobr)');
% % % % % 
% % % % % Ioc = imclose(Io, se);
% % % % % figure, imagesc(Ioc), title('Opening-closing (Ioc)');
% % % % % 
% % % % % Iobrd = imdilate(Iobr, se);
% % % % % Iobrcbr = imreconstruct(imcomplement(Iobrd), imcomplement(Iobr));
% % % % % Iobrcbr = imcomplement(Iobrcbr);
% % % % % figure, imagesc(Iobrcbr), title('Opening-closing by reconstruction (Iobrcbr)');
% % % % % 
% % % % % fgm = imregionalmin(Iobrcbr);
% % % % % figure, imagesc(fgm), title('Regional maxima of opening-closing by reconstruction (fgm)');
% % % % % 
% % % % % I2 = I;
% % % % % I2(fgm) = 255;
% % % % % figure, imagesc(I2), title('Regional maxima superimposed on original image (I2)');
% % % % % 
% % % % % se2 = strel(ones(7,7));
% % % % % fgm2 = imclose(fgm, se2);
% % % % % fgm3 = imerode(fgm2, se2);
% % % % % fgm4 = bwareaopen(fgm3, 20);
% % % % % I3 = I;
% % % % % I3(fgm4) = 255;
% % % % % figure, imagesc(I3), title('Modified regional maxima superimposed on original image (fgm4)');
% % % % % 
% % % % % bw = im2bw(Iobrcbr, graythresh(Iobrcbr));
% % % % % figure, imagesc(bw), title('Thresholded opening-closing by reconstruction (bw)');
% % % % % 
% % % % % D = bwdist(bw);
% % % % % DL = watershed(D);
% % % % % bgm = DL == 0;
% % % % % figure, imagesc(bgm), title('Watershed ridge lines (bgm)');
% % % % % 
% % % % % gradmag2 = imimposemin(gradmag, bgm | fgm4);
% % % % % L = watershed(gradmag2);
% % % % % I4 = I;
% % % % % I4(imdilate(L == 0, ones(3, 3)) | bgm | fgm4) = 255;
% % % % % figure, imagesc(I4), title('Markers and object boundaries superimposed on original image (I4)');
% % % % % 
% % % % % Lrgb = label2rgb(L, 'jet', 'w', 'shuffle');
% % % % % figure, imagesc(Lrgb), title('Colored watershed label matrix (Lrgb)');
% % % % % 
% % % % % figure, imagesc(I), hold on
% % % % % himage = imagesc(Lrgb);
% % % % % set(himage, 'AlphaData', 0.3);
% % % % % title('Lrgb superimposed transparently on original image');

        %%%%%
        W = watershed(Bin_Masks{k});
        figure, imagesc(originalImage{k});colormap gray;
        titlestring='Original  ';
    title(titlestring,'color','k');axis ('image','off');
     figure, imagesc(Bin_Masks{k});colormap gray;
      titlestring='Msk ';
     title(titlestring,'color','k');axis ('image','off');colormap gray;
%         figure, imagesc(Bin_Masks{k});
%         axis([236 738 96 572]);
%         Bin_Mask2 = ~bwareaopen(~Bin_Masks{k}, 50);
%         figure, imagesc(Bin_Mask2);
%         titlestring='after bwareaopen  ';
%     title(titlestring,'color','k');axis([236 738 96 572]);
        % Dist_Transf = -bwdist(~Bin_Masks{k});
        Dist_Transf = bwdist(Bin_Masks{k})-bwdist(~Bin_Masks{k});
         figure, imagesc(Dist_Transf);
         titlestring='Distance transf of mask  ';
     title(titlestring,'color','k');axis ('image','off');
        LDist_Transf = watershed(Dist_Transf);
         figure, imagesc(label2rgb(LDist_Transf))
        titlestring='watershed of distance transform  ';
     title(titlestring,'color','k');axis ('image','off');
  
        Bin_Mask2 = Bin_Masks{k};
        Bin_Mask2(LDist_Transf == 0) = 0;
%         figure, imagesc(Bin_Mask2);titlestring='Separation Water-Dist';
%     title(titlestring,'color','k');
    figure, imshowpair(originalImage{k},LDist_Transf == 0,'falsecolor'); colorbar;
    titlestring='boundaries showing the SKIZ of each cell where oversegmentation';
    title(titlestring,'color','k');axis ('image','off');
    figure, imshowpair(originalImage{k},LDist_Transf == 0,'blend');
    titlestring='boundaries showing the SKIZ of each cell where oversegmentation';
    title(titlestring,'color','k');axis ('image','off');
    figure, imagesc(Bin_Mask2);titlestring='Separation Water-Dist';
    title(titlestring,'color','k');axis ('image','off');colormap gray;
%         axis([236 738 96 572]);
        Imextendedmin_Dist_Transf = imextendedmin(Dist_Transf, 0.42);%5 for Sim4  %1  0.75  0.5 better separation for hela2
         %computes the extended-minima transform, which is the regional minima of the H-minima transform. Regional minima are connected components of pixels with a constant intensity value, and whose external boundary pixels all have a higher value.
         % h is a nonnegative scalar. By default, imextendedmin uses 8-connected neighborhoods for 2-D images and 26-connected neighborhoods for 3-D images. 
        figure, imshowpair(Bin_Masks{k},Imextendedmin_Dist_Transf,'diff');
       titlestring='Modified Regional Minima Superimposed on the DT';  %Modified regional minima superimposed on original image 
    title(titlestring,'color','k');axis ('image','off');%colorbar;
    
          figure, imshowpair(Bin_Masks{k},Imextendedmin_Dist_Transf,'blend')
       titlestring='Modified regional minima superimposed on DT';  %Modified regional minima superimposed on original image 
    title(titlestring,'color','k');axis ('image','off');%colorbar;
    
        Dist_Transf2 = imimposemin(Dist_Transf,Imextendedmin_Dist_Transf);
        %We modify the distance transform using morphological reconstruction so it only has regional minima 
        % wherever Imextendedmin_Dist_Transf is nonzero we impose the minima. 
        LDist_Transf2 = watershed(Dist_Transf2);
        Bin_Mask3 = Bin_Masks{k};
        Bin_Mask3(LDist_Transf2 == 0) = 0;
       figure, imagesc(Bin_Mask3);titlestring='New mask after Cell separation';
    title(titlestring,'color','k');axis ('image','off');colormap gray;
    
     figure, imshowpair(originalImage{k},LDist_Transf2 == 0,'falsecolor');titlestring='Final result of cell separation ';
    title(titlestring,'color','k');axis ('image','off');colorbar;
    figure, imshowpair(originalImage{k},LDist_Transf2 == 0,'blend');titlestring='Final result of cell separation ';
    title(titlestring,'color','k');axis ('image','off');colormap gray;
    
    end;
    drawnow();
end
AllLabels = bwlabeln(AllMasks, 6);

%for k = 1 :25:Nb_Masks

    k=73 ;
    M= Bin_Masks{k};
    
    labeled_im  = bwconncomp(M, 4);
    
    
    
    
    
    numPixels = cellfun(@numel,labeled_im.PixelIdxList);
    % Number of pixels in each label  equivalent to area if we want to remove the small
    % cells less than thresh area Thresh_Area as pre-tracking step
    % for i= 1 : size(numPixels)
    %     if (numPixels(i) <= Thresh_Area)
    %         labeled_im.PixelIdxList{i} = 0;
    %     end;
    % end;
    
    %Nb_Cells_masks(k)=Nb_cells_Mask;    % number of cells in motion image
    
    
    
    L    = labelmatrix(labeled_im);  % is a mapping Create different label to each cell
    
    % After calling regionprops   Nb_Cells_masks(k)=Nb_cells_Mask;    % number of cells in motion image
    % Reg_label = regionprops(L);   might not be needed
    
    
    % write later imwrite(L,strcat(workFolder,Label_Name,'local',num2str(k-1),'.tiff'));
    
    
    
    figure,subplot(2,1,1);imagesc(M);colormap 'gray',
    titlestring=['Binary Mask '];  % cells before removing small areas  ????
    title(titlestring,'color','k');
    axis ('image','off');
    subplot(2,1,2);imagesc(label2rgb(L));
    titlestring=['label Mask  ' ];
    title(titlestring,'color','k');
    axis ('image','off');
    % After calling regionprops Nb_Cells_masks(k)=Nb_cells_Mask;    % number of cells in motion image
    %  save later  saveas(gcf,strcat(workFolder,Label_Name,'SIM4_nb_',num2str(k-1),'.png'), 'png');
    
    coloredLabels = label2rgb (AllLabels(:,:,k), 'hsv', 'k', 'shuffle'); % to have better visual
    
    %imagesc(coloredLabels);
    %
    %coloredLabels = label2rgb (AllLabels, 'hsv', 'k', 'shuffle');
    
    %subplot(3, 2, 1);
    figure, colormap 'gray',imagesc(label2rgb(L));titlestring='labeled images';
    title(titlestring,'color','k');axis ('image','off');
    axis image;axis off,
    
    % Get all the cell features
    
    cellMeasurements = regionprops(L, 'all');
    %'Solidity' — Scalar specifying the proportion of the pixels in the convex hull that are also in the region.
    % Computed as Area/ConvexArea. This property is supported only for 2-D input label matrices.
    figure, plot(sort([cellMeasurements.Solidity]),'-b.');
    titlestring='Proportions of the pixels in the convex hull of all the regions of the frame.';
    title(titlestring,'color','k');axis ('image','off');
    Thresh_solidity = 0.96;    %  SIM04  thres =0.8926 smallest other .95, 0.9 for hela2
    UniqueCell = [cellMeasurements.Solidity]>Thresh_solidity;
    Cell_Cluster = ~UniqueCell;
    %%%%%%      Cell_Cluster = [cellMeasurements.Solidity]<= Thresh_solidity;
    % Make an image showing single/multi cells
    M_empty  = false(size(M));
    M_multi= false(size(M));
    %[M_empty,M_multi] = deal(false(size(M)));
    M_multi(cat(1,labeled_im.PixelIdxList{Cell_Cluster})) = true;
    
    
    figure,
    set(gcf, 'Units','Normalized','OuterPosition',[0 0 1 1]);
    imagesc(double(M_multi)), colormap gray;axis image; axis off,titlestring='Estimate of the number of cells in each cluster based.';
    title(titlestring,'color','k');axis ('image','off'); hold on
    % expected number of cells in a cluster based on solidity
    estimatedCellArea = mean([cellMeasurements(UniqueCell).Area]);
    estimated_nb_Cells = round([cellMeasurements(Cell_Cluster).Area] / estimatedCellArea);
    multiCentroids = cat(1,cellMeasurements(Cell_Cluster).Centroid);
    text(multiCentroids(:,1),multiCentroids(:,2), num2str(estimated_nb_Cells'), 'Color','b','FontWeight','bold')
    hold off;
    numberOfcells = size(cellMeasurements, 1);
    % bwboundaries() returns a cell array, where each cell contains the row/column coordinates for an object in the image.
    % Plot the boundaries of all the cells on the original grayscale image using the results from bwboundaries.
    % subplot(3, 3, 6);
    figure, colormap 'gray',
    % Maximize the figure window
	set(gcf, 'Units','Normalized','OuterPosition',[0 0 1 1]);
    colormap 'gray',
    Orig=originalImage{k};
    imagesc(Orig);titlestring='Labels and Boundaries of each cell';
    title(titlestring,'color','k');
    axis image; axis off,
    hold on;
    boundaries = bwboundaries(M);
    numberOfBoundaries = size(boundaries, 1);
    for k = 1 : numberOfBoundaries
        thisBoundary = boundaries{k};
        plot(thisBoundary(:,2), thisBoundary(:,1), 'g', 'LineWidth', 0.8);
    end
    hold off;
    
    textFontSize = 10;
    labelShiftX = -7;	% Used to align the labels in the centers of the cells.
    cellECD = zeros(1, numberOfcells);
    % Print header line in the command window.
    fprintf(1,'cell #      Mean Intensity  Area  Perimeter    Centroid   Solidity Orientation\n');
    % cell measurements
    for k = 1 : numberOfcells
        % Find the mean of each cell.
        thiscellPixels = cellMeasurements(k).PixelIdxList;  % Get list of pixels in current cell.
        meancell = mean(Orig(thiscellPixels)); % Find mean intensity (in original image!)
        cellArea = cellMeasurements(k).Area;		        % Get area.
        cellPerimeter = cellMeasurements(k).Perimeter;		% Get perimeter.
        cellCentroid = cellMeasurements(k).Centroid;		% Get centroid one by one
        cellSolidity=cellMeasurements(k).Solidity;
        cellOrient=cellMeasurements(k).Orientation;
        fprintf(1,'#%2d %17.1f %11.1f %8.1f %8.1f %8.1f % 8.2f % 8.1f\n', k, meancell, cellArea, cellPerimeter, cellCentroid, cellSolidity, cellOrient);
        % Put the "cell number" labels on the "boundaries" grayscale image.
        text(cellCentroid(1) + labelShiftX, cellCentroid(2), num2str(k),'color','y', 'FontSize', 10,'FontWeight','bold');
    end
    
    
    %  centroids of ALL the cells into 2 arrays:  xpositions and y positions
    
    allcellCentroids = cat(1,cellMeasurements.Centroid);
    centroidsX = allcellCentroids(:, 1);
    centroidsY = allcellCentroids(:, 2);
    
    % figure,
    %
    % for k = 1 : numberOfcells           % Loop through all cells.
    % 	text(centroidsX(k) + labelShiftX, centroidsY(k), num2str(k), 'FontSize', 10, 'Fontname', 'Cambria');
    % end
    
    %%%%%%%%allcellIntensities = [cellMeasurements.MeanIntensity];
    allcellAreas = [cellMeasurements.Area];
    % Get a list of the cells that verify criteria logic
    
    %%%%%%%%%allowableIntensityIndexes = (allcellIntensities > 150) & (allcellIntensities < 220);
    allowableAreaIndexes = allcellAreas > 100; % Take the small cells
    
    %keepIndexes = find(allowableIntensityIndexes & allowableAreaIndexes);
    keepIndexes = find( allowableAreaIndexes);
    % Extract only those cells that meet our criteria, and
    % eliminate those cells that don't meet our criteria.
    %  ismember() to do this.  Result will be an image - the same as AllLabels but with only the cells listed in keepIndexes in it.
    keepcellsImage = ismember(L, keepIndexes);
    % Re-label with only the keep cells kept.
    %labelednewImage = bwlabel(keepcellsImage, 4);     % Label each cell so we can make measurements of it
    
    labelednewImage =bwconncomp(keepcellsImage, 4);
    % Now we're done.  We have a labeled image of cells that meet our specified criteria.
    %subplot(3, 3, 7);
    L1    = labelmatrix(labelednewImage);  % mapping Create different label to each cell
    figure, colormap 'gray',titlestring='new labeled Image';
    title(titlestring,'color','k');axis ('image','off');
    imagesc(label2rgb(L1));
    axis image;
    axis off,
    
    % Plot the centroids in the original image
    % news will have a red cross, large will have a blue X.
    %subplot(3, 3, 1);
    figure, colormap 'gray',titlestring='Regions positions. Red: small Regions, blue: large regions (cells)';
    title(titlestring,'color','k');axis ('image','off');
    hold on;
    for p = 1 : numberOfcells           % Loop through all keep cells.
        % Identify if cell #k is a small or big cell
        It_s_a_Cell = allcellAreas(p) > 100; %  small.
        if It_s_a_Cell
            % Plot small with a red +.
            plot(centroidsX(p), centroidsY(p), 'b+', 'MarkerSize', 5, 'LineWidth', 1);
        else
            % Plot bog with a blue *.
            plot(centroidsX(p), centroidsY(p), 'r*', 'MarkerSize', 5, 'LineWidth', 1);
        end
    end
    
    
    % Now use the keep cells as a mask on the original image.
    % This will let us display the original image in the regions of the keep cells.
    maskedImagenew = Orig;
    maskedImagenew(~keepcellsImage) = 0;  % Set all non-keep pixels to zero.
    figure, colormap 'gray',  %subplot(3, 3, 8);
    imagesc(maskedImagenew);
    axis image; axis off,
    title('After small regions removal');
    
    % % Now let's get the larger cell type for cell separation
    % keepIndexes = find(allcellAreas > 2000);  % Take the larger cells
    % % Note how we use ismember to select the cells that meet our criteria.
    % smalllmask = ismember(L, keepIndexes);
    %
    % maskedImagesmalll = Orig;
    % maskedImagesmalll(~smalllmask) = 0;
    % figure, colormap 'gray',  %subplot(3, 3, 9);
    % imshow(maskedImagesmalll, []);
    % axis image;
    % title('Only the smallls from the original image');
    display_each_cell=1;
    if display_each_cell
        figure;	% Create a new figure window.
        
        for p = 1 :4: numberOfcells           % Loop through all cells.
            % Find for each cell.
            thiscellsBoundingBox = cellMeasurements(p).BoundingBox;  % Get list of pixels in current cell.
            % each cell its image
            subImage = imcrop(Orig, thiscellsBoundingBox);
            % Determine if it's a new (small) or a smalll (large cell) include
            % the cell clusters from solidity
            %if cellMeasurements(p).Area > 2200
            cellType = 'Cell';
            %else
            %cellType = 'new';
            %end
            % Display the image with informative caption.
            figure,    %subplot(3, 4, p);
            imagesc(subImage);axis image; axis off,
            caption = sprintf('cell #%d is a %s.\nDiameter = %.1f pixels\nArea = %d pixels', ...
                p, cellType, cellECD(p), cellMeasurements(p).Area);
            title(caption);
        end
    
    
    
    %-------------------------------Save later  !!!!!!!!
    %imwrite(AllLabels(:,:,k),strcat(Glob_Folder,'glocal',num2str(k-1),'.tiff'));
    %saveas(gcf,strcat(Glob_Folder,'nb_',num2str(k-1),'.png'), 'png');
    drawnow();
    
    
    %!!!!!!! Plot the new labeled image after cell separation
    
    labeled_im  = bwconncomp(Bin_Mask3, 4);
    
    L    = labelmatrix(labeled_im);  % is a mapping Create different label to each cell
    cellMeasurements = regionprops(L, 'all');
    
    
    
    numPixels = cellfun(@numel,labeled_im.PixelIdxList);
        
   
    
      
    figure,set(gcf, 'Units','Normalized','OuterPosition',[0 0 1 1]);
   imagesc(label2rgb(L));
    titlestring=['New labeled image after cell separation  ' ];
    title(titlestring,'color','k');
    axis ('image','off');
    % After calling regionprops Nb_Cells_masks(k)=Nb_cells_Mask;    % number of cells in motion image
    %  save later  saveas(gcf,strcat(workFolder,Label_Name,'SIM4_nb_',num2str(k-1),'.png'), 'png');
    
    coloredLabels = label2rgb (AllLabels(:,:,k), 'hsv', 'k', 'shuffle'); % to have better visual
    
    
    numberOfcells = size(cellMeasurements, 1);
    
    % bwboundaries() returns a cell array, where each cell contains the row/column coordinates for an object in the image.
    % Plot the boundaries of all the cells on the original grayscale image using the results from bwboundaries.
    % subplot(3, 3, 6);
    figure, colormap 'gray',
    % Maximize the figure window
	set(gcf, 'Units','Normalized','OuterPosition',[0 0 1 1]);
    colormap 'gray',
    Orig=originalImage{k};
    imagesc(Orig);titlestring='Labels and Boundaries of each cell';
    title(titlestring,'color','k');
    axis image; axis off,
    hold on;
    boundaries = bwboundaries(Bin_Mask3);
    numberOfBoundaries = size(boundaries, 1);
    for k = 1 : numberOfBoundaries
        thisBoundary = boundaries{k};
        plot(thisBoundary(:,2), thisBoundary(:,1), 'g', 'LineWidth', 0.8);
    end
    hold off;
    
    textFontSize = 10;
    labelShiftX = -7;	% Used to align the labels in the centers of the cells.
    cellECD = zeros(1, numberOfcells);
    % Print header line in the command window.
    fprintf(1,'cell #      Mean Intensity  Area  Perimeter    Centroid   Solidity Orientation\n');
    % cell measurements
    for k = 1 : numberOfcells
        % Find the mean of each cell.
        thiscellPixels = cellMeasurements(k).PixelIdxList;  % Get list of pixels in current cell.
        meancell = mean(Orig(thiscellPixels)); % Find mean intensity (in original image!)
        cellArea = cellMeasurements(k).Area;		        % Get area.
        cellPerimeter = cellMeasurements(k).Perimeter;		% Get perimeter.
        cellCentroid = cellMeasurements(k).Centroid;		% Get centroid one by one
        cellSolidity=cellMeasurements(k).Solidity;
        cellOrient=cellMeasurements(k).Orientation;
        fprintf(1,'#%2d %17.1f %11.1f %8.1f %8.1f %8.1f % 8.2f % 8.1f\n', k, meancell, cellArea, cellPerimeter, cellCentroid, cellSolidity, cellOrient);
        % Put the "cell number" labels on the "boundaries" grayscale image.
        text(cellCentroid(1) + labelShiftX, cellCentroid(2), num2str(k),'color','y', 'FontSize', 10,'FontWeight','bold');
    end
    
    
    
    
end;









