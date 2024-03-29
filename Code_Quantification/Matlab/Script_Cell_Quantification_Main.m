%%
close all; clc;

%% Datasets Folder path
% all the frames at DESU
%% Data location and information.

if ispc
    user_folder = getenv('USERPROFILE');
    work_folder = fullfile(user_folder,'Documents','code','1data-lab','CSTQ','2Modify');
elseif ismac
    user_folder = getenv('HOME');
    work_folder = fullfile(user_folder,'Documents','code','1data-lab','CSTQ','2Modify');
else
    user_folder = getenv('HOME');
    work_folder = fullfile(user_folder,'Documents','code','1data-lab','CSTQ','2Modify');
    if exist(work_folder)==7
        disp('data dir ready');
    else
        disp('data dir can not read');
    end
end


% Root folder for data.
% work_folder = fullfile(user_folder,'OneDrive - Delaware State University','Documents','Data','Cell_Tracking_Challenge',...
%     'Training');

param_excel_path = 'Parameters.csv';          % on current folder
Parameter_Table = readtable(param_excel_path,'VariableNamingRule','preserve');
Dataset_Names = Parameter_Table.Dataset_Name(1:26);
%[~, ~, DatasetNames] = xlsread(param_excel_path, 1, 'A2:A28');

if ismac || isunix
    Dataset_Names = strrep(Dataset_Names,'\','/');
elseif ispc
    % Code to run on Windows platform
else
    disp('Platform not supported')
end

data_nb           = menu('Dataset name:', Dataset_Names);
dataset_name      = Dataset_Names{data_nb};   % SIM1(1)   MSC1(7)  GOWT1(11)  Hela1(9)
sequence_name     = strcat(dataset_name(1:end-3),dataset_name(end-1:end));

pixel_resolutions = [0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.397, 0.397, 0.644, 0.644, 0.24, 0.24, 0.125, 0.125, 0.65, 0.65, 1.6, 1.6, 0.65, 0.65, 0.19, 0.19, 0.645, 0.645, 0.645, 0.645, 0.665];
time_resolutions = [1, 1, 1, 1, 1, 1, 20, 30, 30, 30, 5, 5, 29, 29, 15, 15, 10, 10, 15, 15, 10, 10, 5, 5, 5, 5, 14.8];

metadata.pixel_resolution = pixel_resolutions(data_nb);
metadata.time_resolution = time_resolutions(data_nb);

%local labels to start tracking at the tracking result are folder frames with global labels unique label for each cell throughout the whole data sequence
%C:\Users\Public\data_02_19_2015\Fluo-N2DH-SIM\01_Msk

% Call main quantification function.
% Optional input: parameter structure.
Tracking_Structure = Cell_Quantification_Main(work_folder, dataset_name, metadata);
disp("Quantification Done");
