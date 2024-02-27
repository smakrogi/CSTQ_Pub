%%
% clear all; close all;
close all;
clc;
%Folder that contains all the masks on desktop for testing;
%workFolder='C:\Users\fboukari\Desktop\Tracking_Masks_Results\';
%workFolder='C:\Users\Public\data_02_19_2015\______BEST MASKS Keep Hela_2Motion_sig20_lambda0.1_TSRatio100\';

%   Binary masks of each dataset is at:   0nb_Msk
%workFolder='C:\Users\Public\data_02_19_2015\Fluo-C2DL-MSC\';
%workFolder='C:\Users\Public\data_02_19_2015\Fluo-N2DH-GOWT1\';
%workFolder='C:\Users\Public\data_02_19_2015\Fluo-N2DH-SIM\';
%workFolder='C:\Users\Public\data_02_19_2015\Fluo-N2DL-HeLa\';
% local labels to start tracking at the tracking result is folder frames with global labels unique label for each cell throughout the whole data sequence
%   C:\Users\Public\data_02_19_2015\Fluo-N2DH-SIM\01_Msk
%  toshiba hard drive   F:\datasets\C2DL-MSC
Mask_Name   = '_Msk\';        %  name of folder containing the binary masks (input)
Label_Name  = '_Local\';  % name of foler that will contain the lable masks (output)




%(((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Datasets Folder path
% all the frames at Toshiba
%workFolder   ='C:\Users\Public\Data\Cell_Tracking_Challenge\Training\';
% all the frames at DESU
%workFolder   ='C:\Users\Public\data_02_19_2015\';
workFolder   ='C:\Users\fboukari\ownCloud\Fatima_Boukari\New data\';
% Parameters:
%   Threshold value for Size of cells to remove and 
%   Solidity threshold for cell separation
%    
%Excel_Name_Size_Solidity = 'Tracking_Parameters.xlsx';   

DatasetNames      = Data_Names;%   For now we have SIM04= 4 and Hela2 =10
Data_Nb           = menu('Dataset name: 2 4 or 10 for now ' ,'Fluo-N2DH-SIM\01' ,'Fluo-N2DH-SIM\02',...
    'Fluo-N2DH-SIM\03' ,'Fluo-N2DH-SIM\04' ,'Fluo-N2DH-SIM\05',...
    'Fluo-N2DH-SIM\06' ,'Fluo-C2DL-MSC\01' ,'Fluo-C2DL-MSC\02',...
    'Fluo-N2DL-HeLa\01','Fluo-N2DL-HeLa\02','Fluo-N2DH-GOWT1\01',...
    'Fluo-N2DH-GOWT1\02');
dataset_name          = DatasetNames{Data_Nb};   % SIM1(1)   MSC1(7)  GOWT1(11)  Hela1(9)
Nom                   = strcat(dataset_name(1:end-3),dataset_name(end-1:end));

% call function to import Parameters for each dataset from Excel See if we will need different values                            %
% The Excel file Tracking_Parameters.xlsx contains:  Threshold value for Size of cells to remove and 
%   Solidity threshold for cell separation
%[Threshold_Size, Threshold_Solidity] = Get_Tracking_Parameters(Excel_Name_Size_Solidity,Data_Nb);

Orig_Folder=   strcat(workFolder,dataset_name);
%  '\',dataset_name(end-1:end)
Mask_Folder=strcat(Orig_Folder,Mask_Name);

Thresh_Area  = 45;                             % Will be set as parameter later
Glob_Folder =strcat(Orig_Folder,'_Global\');
%% Call to get all the binary masks in a cell array

[Bin_Masks,Nb_Masks] = Get_Binary_Masks(Mask_Folder, 7); %the number of masks numel(Bin_Masks);
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

%coloredLabels = label2rgb (AllLabels, 'hsv', 'k', 'shuffle'); % to have better visual

%imagesc(coloredLabels);

for k = 1 :25:Nb_Masks

    M= Bin_Masks{k};

    [ New_Intensity_Image, New_Region_Mask] = Post_Segmentation( originalImage{k}, M ,Nom,Thresh_Area);
    CC_Structure  = bwconncomp(M,4);    %New_Region_Mask, 4);
    
    L    = labelmatrix(CC_Structure);  % is a mapping Create different label to each cell

    [ Cell_Features ] = Compute_Cell_Features( originalImage{k}, L, CC_Structure );
      
end;















