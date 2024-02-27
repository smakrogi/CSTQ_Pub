% Script for cell tracking using segmentation masks in a loop for multiple sequences.
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
work_folder = fullfile(user_folder,'Documents','Data','Cell_Tracking_Challenge','Training');

DatasetNames      = Data_Names; % For now we have SIM04= 4 and Hela2 =10

for Data_Nb=1:length(DatasetNames)
    dataset_name          =   DatasetNames{Data_Nb};   % SIM1(1)   MSC1(7)  GOWT1(11)  Hela1(9)
    
    % Call main tracking function.
    % Optional input: parameter structure.
    Tracking_Structure = Cell_Tracking_MIVICLAB_Main(work_folder, dataset_name);
end

% To validate:
% start cygwin X-server
% start xterm
% cd '/cygdrive/c/Users/fboukari/ownCloud/Fatima_Boukari/From_Fatima/CODE_06_2015/Code_Tracking/EvaluationSoftware'
% ./Win/TRAMeasure.exe "C:\Users\fboukari\ownCloud\Fatima_Boukari\New data\Fluo-N2DH-SIM" 01

