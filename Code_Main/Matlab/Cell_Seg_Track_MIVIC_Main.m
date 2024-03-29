function [Segmentation_Results_Cell, Tracking_Structure] = ...
    Cell_Seg_Track_MIVIC_Main(sequence_name, sequence_number)
% Function for cell tracking using segmentation masks for a single sequence.
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

work_folder = fullfile(user_folder,'Documents','Data','Cell_Tracking_Challenge',...
    'Challenge');
param_excel_path = 'Challenge_Parameters.xlsx';          % on current folder

dataset_name = [sequence_name, '\', sequence_number]; %'Fluo-N2DH-SIM\03';

% Call main tracking function.
Segmentation_Results_Cell = Cell_Segmentation_MIVICLAB_Main(work_folder, ...
    dataset_name, param_excel_path);

% Call main tracking function.
% Optional input: parameter structure.
Tracking_Structure = Cell_Tracking_MIVICLAB_Main(work_folder, dataset_name);

% To validate:
% start cygwin XWin-server
% start xterm
% cd 'Code_Tracking/EvaluationSoftware'
% ./Win/TRAMeasure.exe "Data\Fluo-N2DH-SIM" 01



end