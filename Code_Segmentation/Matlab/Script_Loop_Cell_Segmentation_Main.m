% Script for cell segmentation in a loop for multiple sequences.
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
param_excel_path = 'Challenge_Parameters.xlsx';          % on current folder

Parameter_Table = readtable(param_excel_path,'VariableNamingRule','preserve');
Dataset_Names = Parameter_Table.Dataset_Name(1:26);

if ismac || isunix
    Dataset_Names = strrep(Dataset_Names,'\','/');
elseif ispc
    % Code to run on Windows platform
else
    disp('Platform not supported')
end

for Data_Nb=[7:10, 13:18, 21:22]
    dataset_name = Dataset_Names{Data_Nb};   % SIM1(1)   MSC1(7)  GOWT1(11)  Hela1(9)
    
	% Call cell segmentation.
	Segmentation_Results_Cell = Cell_Segmentation_MIVICLAB_Main(work_folder, ...
		dataset_name, param_excel_path);
end

% To validate:
% start X-server
% start xterm
% cd './Code_Tracking/EvaluationSoftware'
% ./Win/TRAMeasure.exe "./Newdata/Fluo-N2DH-SIM" 01

