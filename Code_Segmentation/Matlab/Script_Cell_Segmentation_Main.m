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
    'Training');
param_excel_path = 'Parameters.xlsx';          % on current folder

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[~, ~, DatasetNames] = xlsread(param_excel_path, 1, 'A2:A27');
if ismac
    DatasetNames = strrep(DatasetNames,'\','/');
elseif isunix
    DatasetNames = strrep(DatasetNames,'\','/');
elseif ispc
    % Code to run on Windows platform
else
    disp('Platform not supported')
end

data_nb           = menu('Dataset name:', DatasetNames);

dataset_name      = DatasetNames{data_nb};   % SIM1(1)   MSC1(7)  GOWT1(11)  Hela1(9)

% Call segmentation.
Segmentation_Results_Cell = Cell_Segmentation_MIVICLAB_Main(work_folder, ...
    dataset_name, param_excel_path);
