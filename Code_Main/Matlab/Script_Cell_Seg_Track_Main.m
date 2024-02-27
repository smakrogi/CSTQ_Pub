% Script for cell tracking using segmentation masks for a single sequence.
% S. Makrogiannis, MIVIC, PEMACS, DESU <smakrogiannis@desu.edu>
close all; clc;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Datasets Folder path
% all the frames at DESU
%% Data location and information.
if ispc
    user_folder = getenv('USERPROFILE');
    work_folder = fullfile(user_folder,'Documents','code','1data-lab','CSTQ','2Modify');
    %work_folder = fullfile('D:','code','1data-lab','CSTQ','2Modify');
    code_work_folder = fileparts(which('README.md'));
elseif ismac
    user_folder = getenv('HOME');
    work_folder = fullfile(user_folder,'Documents','code','1data-lab','CSTQ','2Modify');
    code_work_folder = fileparts(which('README.md'));
else
    user_folder = getenv('HOME');
    work_folder = fullfile(user_folder,'Documents','code','1data-lab','CSTQ','2Modify');
    code_work_folder = fileparts(which('README.md'));
end

% Root folder for data.
%work_folder = fullfile(user_folder,'Documents','Data','Cell_Tracking_Challenge','Training');
if exist(work_folder)==7
    disp('data dir ready');
    disp(work_folder);
else
    disp('data dir can not read');
end

% Root folder for data.
%work_folder = fullfile(user_folder,'Documents','Data','Cell_Tracking_Challenge','Training');

param_excel_path = 'Parameters.xlsx';          % on current folder

DatasetNames      = Data_Names;
data_nb           = menu('Dataset name:', DatasetNames);
dataset_name      = DatasetNames{data_nb};   % SIM1(1)   MSC1(7)  GOWT1(11)  Hela1(9)

% make program run on linux, Mac, etc. platforms
dataset_name=Util_DatasetNameRep(dataset_name);

% Call main segmentation function.
Segmentation_Results_Cell = Cell_Segmentation_MIVICLAB_Main(work_folder, ...
    dataset_name, param_excel_path);

% Call main tracking function.
% Optional input: parameter structure.
Tracking_Structure = Cell_Tracking_MIVICLAB_Main(work_folder, dataset_name);

% To validate:
% start cygwin XWin-server
% start xterm
% cd '/cygdrive/c/Users/fboukari/ownCloud/Fatima_Boukari/From_Fatima/CODE_06_2015/Code_Tracking/EvaluationSoftware'
% ./Win/TRAMeasure.exe
% "C:\Users\fboukari\ownCloud\Fatima_Boukari\Data\Fluo-N2DH-SIM" 01 03



