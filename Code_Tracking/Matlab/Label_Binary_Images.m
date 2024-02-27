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
% local labels to start tracking at the tracking result is folder frames with global labels unique label for each cell throughout the whole data sequence
%   C:\Users\Public\data_02_19_2015\Fluo-N2DH-SIM\01_Msk

Mask_Name   = '04_Msk\';        %  name of folder containing the binary masks (input)
Label_Name  = '04_Local\';  % name of foler that will contain the lable masks (output) 
Mask_Folder=strcat(workFolder,Mask_Name);
Thresh_Area  = 50;
Glob_Folder =strcat(workFolder,'04_Global\');
%% Call to get all the binary masks in a cell array 

[Bin_Masks,Nb_Masks] = Get_Binary_Masks(Mask_Folder); %the number of masks numel(Bin_Masks);
Nb_Masks=numel(Bin_Masks);
AllMasks = zeros([size(Bin_Masks{1}), Nb_Masks]);

%% Read all the masks
% each mask is referred    im = double(Bin_Masks{i})
Nb_Cells_masks = zeros(Nb_Masks);
%dataset_name          = DatasetNames{Data_Nb};   % SIM1(1)   MSC1(7)  GOWT1(11)  Hela1(9)
%Nom                   = strcat(dataset_name(11:end-3),dataset_name(end-1:end));
for k = 1 :Nb_Masks
   %Create 3D stack image     
   AllMasks(:,:,k) = Bin_Masks{k};
end
AllLabels = bwlabeln(AllMasks, 6);
 for k = 1 :Nb_Masks
    M= Bin_Masks{k};
                 
    labeled_im  = bwconncomp(M, 4);
  %  returns a matrix L, of the same size as labeled_im
%   containing labels for the connected components in BW.
%   pixels labeled 0 are the background.  The pixels labeled 1 make up one
%   object, the pixels labeled 2 make up a second object, and so on.t  
% % % % % A = bwconncomp(mask);
% % % % % numPixels = cellfun(@numel,A.PixelIdxList);
% % % % % [biggest,idx] = max(numPixels);
% % % % % mask(CC.PixelIdxList{idx}) = 0;



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
% Note that labelmatrix is more memory efficient than bwlabel , 
%using the smallest numeric class necessary for the number of objects.
% The functions bwlabel, bwlabeln, and bwconncomp all compute connected components 
   % for binary images. bwconncomp replaces the use of bwlabel and bwlabeln. It uses significantly less memory and is sometimes faster than the other functions.
    
   
  L    = labelmatrix(labeled_im);  % mapping Create different label to each cell
  % Note that labelmatrix is more memory efficient than bwlabel , 
%using the smallest numeric class necessary for the number of objects.
           % After calling regionprops   Nb_Cells_masks(k)=Nb_cells_Mask;    % number of cells in motion image
   % Reg_label = regionprops(L);   might not be needed        
 
   
   
 imwrite(L,strcat(workFolder,Label_Name,'local',num2str(k-1),'.tiff'));          
   
    
   
   figure,subplot(2,1,1);imagesc(M);
   titlestring=['Binary Mask '];  % cells before removing small areas  ????
    title(titlestring,'color','k'); 
    axis ('image','off');
    subplot(2,1,2);imagesc(label2rgb(L));
    titlestring=['label Mask  ' ];
   title(titlestring,'color','k');
    axis ('image','off');
    % After calling regionprops Nb_Cells_masks(k)=Nb_cells_Mask;    % number of cells in motion image
  saveas(gcf,strcat(workFolder,Label_Name,'SIM4_nb_',num2str(k-1),'.png'), 'png');
  
  figure, imagesc(label2rgb(AllLabels(:,:,k))); 
  imwrite(AllLabels(:,:,k),strcat(Glob_Folder,'glocal',num2str(k-1),'.tiff'));         
  saveas(gcf,strcat(Glob_Folder,'nb_',num2str(k-1),'.png'), 'png');
  
end;









