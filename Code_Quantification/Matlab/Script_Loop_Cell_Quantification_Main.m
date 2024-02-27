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
work_folder = fullfile(user_folder,'Documents','Data','Cell_Tracking_Challenge','Training');
param_excel_path = 'Parameters.xlsx';          % on current folder
[~, ~, DatasetNames] = xlsread(param_excel_path, 1, 'A2:A27');

% To Do: update resolutions.
pixel_resolutions = [0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.397, 0.397, 0.644, 0.644, 0.24, 0.24, 0.125, 0.125, 0.65, 0.65, 1.6, 1.6, 0.65, 0.65, 0.19, 0.19, 0.645, 0.645, 0.645, 0.645];
time_resolutions = [1, 1, 1, 1, 1, 1, 20, 30, 30, 30, 5, 5, 29, 29, 15, 15, 10, 10, 15, 15, 10, 10, 5, 5, 5, 5];

for Data_Nb=1:length(DatasetNames)
    metadata.pixel_resolution = pixel_resolutions(data_nb);
    metadata.time_resolution = time_resolutions(data_nb);
    dataset_name = DatasetNames{Data_Nb};   % SIM1(1)   MSC1(7)  GOWT1(11)  Hela1(9)
    Tracking_Structure = Cell_Quantification_Main(work_folder, dataset_name, metadata);
end

% To validate:
% start cygwin X-server
% start xterm
% cd '/cygdrive/c/Users/fboukari/ownCloud/Fatima_Boukari/From_Fatima/CODE_06_2015/Code_Tracking/EvaluationSoftware'
% ./Win/TRAMeasure.exe "C:\Users\fboukari\ownCloud\Fatima_Boukari\New data\Fluo-N2DH-SIM" 01

