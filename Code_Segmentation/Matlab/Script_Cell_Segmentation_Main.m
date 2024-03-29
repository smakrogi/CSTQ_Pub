%     Chan Vese, Temporal linking and non linear diffusion
%   input parameters set =1 Run this code for only simulated datasets
%   Nearest neighbor undersampling                                         
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% F. Boukari, MIVIC, PEMACS, DESU
% S. Makrogiannis, MIVIC, PEMACS, DESU <smakrogiannis@desu.edu>

% Train_data and Reference_data are cell arrays x{i}
% Numero_Train end  Numero_Ref: Arrays of primitives (double)

% clear all; clc;
close all;   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Datasets Folder path
% all the frames at DESU
%% Data location and information.
if ispc
    user_folder = getenv('USERPROFILE');
else
    user_folder = getenv('HOME');
end

work_folder = fullfile(user_folder,'Documents','Data','Cell_Tracking_Challenge',...
    'Challenge');
param_excel_path = 'Challenge_Parameters.csv';          % on current folder

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Parameter_Table = readtable(param_excel_path,'VariableNamingRule','preserve');
Dataset_Names = Parameter_Table.Dataset_Name(1:26);
if ismac || isunix
    Dataset_Names = strrep(Dataset_Names,'\','/');
elseif ispc
    % Code to run on Windows platform
else
    disp('Platform not supported')
end

data_nb           = menu('Dataset name:', Dataset_Names);

dataset_name      = Dataset_Names{data_nb};   % SIM1(1)   MSC1(7)  GOWT1(11)  Hela1(9)

% Call segmentation.
Segmentation_Results_Cell = Cell_Segmentation_MIVICLAB_Main(work_folder, ...
    dataset_name, param_excel_path);
