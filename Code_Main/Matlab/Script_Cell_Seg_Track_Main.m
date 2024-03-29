% Script for cell tracking using segmentation masks for a single sequence.
% S. Makrogiannis, MIVIC, PEMACS, DESU <smakrogiannis@desu.edu>
close all; 

%% Datasets Folder path
% all the frames at DESU
%% Data location and information.
if ispc
    user_folder = getenv('USERPROFILE');
else
    user_folder = getenv('HOME');
end

work_folder = fullfile(user_folder,'Documents','Data','Cell_Tracking_Challenge','Challenge');

% Root folder for data.
if exist(work_folder,'dir')==7
    disp('data dir ready');
    disp(work_folder);
else
    error('can not read data dir');
end

param_excel_path = 'Challenge_Parameters.csv';          % on current folder
Parameter_Table = readtable(param_excel_path,'VariableNamingRule','preserve');
Dataset_Names = Parameter_Table.Dataset_Name(1:26);

if ismac
    Dataset_Names = strrep(Dataset_Names,'\','/');
elseif isunix
    Dataset_Names = strrep(Dataset_Names,'\','/');
elseif ispc
    % Code to run on Windows platform
else
    disp('Platform not supported')
end

data_nb           = menu('Dataset name:', Dataset_Names);
dataset_name      = Dataset_Names{data_nb};   % SIM1(1)   MSC1(7)  GOWT1(11)  Hela1(9)

% Call main segmentation function.
Segmentation_Results_Cell = Cell_Segmentation_MIVICLAB_Main(work_folder, ...
    dataset_name, param_excel_path);

% Call main tracking function.
% Optional input: parameter structure.
Tracking_Structure = Cell_Tracking_MIVICLAB_Main(work_folder, dataset_name);

% To validate:
% start cygwin XWin-server
% start xterm
% cd 'Code_Tracking/EvaluationSoftware'
% ./Win/TRAMeasure.exe
% "Data\Fluo-N2DH-SIM" 01 03



