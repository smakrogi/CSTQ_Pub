function New_Label_Map = Separate_Cell_Clusters(Label_Map, thresh_imextendedmin_dist_transf)
% syntax: New_Label_Map = Separate_Cell_Clusters(Label_Map, thresh_imextendedmin_dist_transf);
% S. Makrogiannis, MIVIC, PEMACS, DESU <smakrogiannis@desu.edu>

%% Algorithm parameters.
% thresh_imextendedmin_dist_transf = 0.5; %5 for Sim4  %1  0.75  0.5 better separation for hela2

%% Generate label from binary map if needed.
if numel(unique(Label_Map))==2
    CC_Structure = bwconncomp(Label_Map, 4);     
    Label_Map    = labelmatrix(CC_Structure);  
end

%% Cell cluster separation on the New_Region_Mask after removal of small regions Region_Mask or Binary_Mask
Dist_Transf = bwdist(Label_Map)-bwdist(~Label_Map);
% figure, imagesc(Dist_Transf);
% titlestring='Distance transf of mask  ';
% title(titlestring,'color','k');axis image; axis off,

% Label_Dist_Transf = watershed(Dist_Transf);
% figure, imagesc(label2rgb(Label_Dist_Transf))
% titlestring='watershed Distance';
% title(titlestring,'color','k');
% axis image; axis off,
% 
% Label_Map_Separated = Label_Map;
% Label_Map_Separated(Label_Dist_Transf == 0) = 0;
% figure, imshowpair(Intensity_Image, Label_Dist_Transf == 0,'falsecolor');axis image; axis off,
% titlestring='Watershed ridges superposed on the original image';
% title(titlestring,'color','k');axis image; axis off,
% figure, imagesc(Label_Map_Separated);titlestring='Label Map showing oversegmented cell separation';
% title(titlestring,'color','k','FontSize', 12, 'Fontname', 'Cambria');axis image; axis off,

% L3 =bwconncomp(Label_Map_Separated, 4);
% L4    = labelmatrix(L3);  % mapping Create different label to each cell
% figure,
% imagesc(label2rgb(L4, 'prism','k', 'shuffle'));titlestring='separated1';
% titlestring='Final result of cell separation';
% title(titlestring,'color','k','FontSize', 12, 'Fontname', 'Cambria');axis image; axis off,
% figure,
% imagesc(label2rgb(L4));titlestring='separated1';
% titlestring='new after watershed dist transform';
% title(titlestring,'color','k','FontSize', 12, 'Fontname', 'Cambria');axis image; axis off;

Imextendedmin_Dist_Transf = imextendedmin(Dist_Transf,thresh_imextendedmin_dist_transf);%5 for Sim4  %1  0.75  0.5 better separation for hela2
% computes the extended-minima transform, which is the regional minima of the H-minima transform. Regional minima are connected components of pixels with a constant intensity value, and whose external boundary pixels all have a higher value.
% h is a nonnegative scalar. By default, imextendedmin uses 8-connected neighborhoods for 2-D images and 26-connected neighborhoods for 3-D images.
% figure, imshowpair(Label_Map,Imextendedmin_Dist_Transf,'falsecolor');
% titlestring='H-minima Transform';
% title(titlestring,'color','k');axis image; axis off,

Dist_Transf2 = imimposemin(Dist_Transf, Imextendedmin_Dist_Transf);

%We modify the distance transform using morphological reconstruction so it only has regional minima
% wherever Imextendedmin_Dist_Transf is nonzero we impose the minima.
Label_Dist_Transf2 = watershed(Dist_Transf2);
Label_Dist_Transf2_Separated = Label_Map;
Label_Dist_Transf2_Separated(Label_Dist_Transf2 == 0) = 0;

% L3 =bwconncomp(Label_Dist_Transf2_Separated, 4);
% L4    = labelmatrix(L3);  % mapping Create different label to each cell
% figure,
% imagesc(label2rgb(L4, 'prism','k', 'shuffle'));titlestring='separated transf2 min imposed'; titlestring='new after watershed dist transform';
% title(titlestring,'color','k');axis image; axis off,
% 
% figure, imagesc(Label_Dist_Transf2_Separated);titlestring='watershed of dist transform of minima imposed';
% title(titlestring,'color','k');axis image; axis off,
% figure, imshowpair(Intensity_Image, Label_Dist_Transf2 == 0,'falsecolor');titlestring='intensuty im and watershed of minima imposed';
% title(titlestring,'color','k');
% drawnow();axis image; axis off,

% Return the last binary mask with the new separated cells
New_Label_Map = Label_Dist_Transf2_Separated;

if numel(unique(Label_Map)) > 2
    New_Label_Map = double(New_Label_Map > 0);
end

end