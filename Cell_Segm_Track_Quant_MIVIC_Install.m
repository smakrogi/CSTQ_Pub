function Cell_Segm_Track_Quant_MIVIC_Install()
% S. Makrogiannis, MIVIC, PEMACS, DESU <smakrogiannis@desu.edu>

% Add directory dependencies.

% Prompt user to choose the root directory.
directory_name = uigetdir(pwd, 'Select Cell_Segm_Track_Quant_MIVIC root folder');

% Set paths for programs and data.
% Add paths to the programs.
% Project structure from github.
addpath(fullfile(directory_name, 'Code_CTC'));
addpath(fullfile(directory_name, 'Code_CTC','Linux'));
addpath(fullfile(directory_name, 'Code_CTC','Mac'));
addpath(fullfile(directory_name, 'Code_CTC','Win'));
addpath(fullfile(directory_name, 'Code_Main', 'Matlab'));
addpath(fullfile(directory_name, 'Code_Segmentation', 'Matlab'));
addpath(fullfile(directory_name, 'Code_Segmentation', 'Matlab', 'bm3d_matlab_package'));
addpath(fullfile(directory_name, 'Code_Segmentation', 'Matlab', 'bm3d_matlab_package', 'bm3d'));
addpath(fullfile(directory_name, 'Code_Segmentation', 'Matlab', 'levelset_seg_biasCorr_v1'));
addpath(fullfile(directory_name, 'Code_Tracking', 'Matlab'));
addpath(fullfile(directory_name, 'Code_Tracking', 'Matlab', 'OpticalFlowCeLiu'));
addpath(fullfile(directory_name, 'Code_Tracking', 'Matlab', 'OpticalFlowCeLiu', 'mex'));
addpath(fullfile(directory_name, 'Code_Quantification', 'Matlab'));
addpath(fullfile(directory_name));

% Save path to matlab's startup directory.
savepath(fullfile(userpath, 'pathdef.m'));
disp('Cell_Segm_Track_Quant_MIVIC paths saved.')
end