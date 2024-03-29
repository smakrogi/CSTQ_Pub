% Script for cell tracking using segmentation masks for a single sequence.
% S. Makrogiannis, MIVIC, PEMACS, DESU <smakrogiannis@desu.edu>
close all; clc;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Datasets Folder path
% all the frames at DESU
%% Data location and information.
if ispc
    user_folder = getenv('USERPROFILE');
else
    user_folder = getenv('HOME');
end

% Root folder for data.
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

% Call main tracking function.
% Optional input: parameter structure.
Tracking_Structure = Cell_Tracking_MIVICLAB_Main(work_folder, dataset_name);

% To validate:
% start cygwin XWin-server
% start xterm
% cd 'Win/TRAMeasure.exe "Data\Fluo-N2DH-SIM" 01

