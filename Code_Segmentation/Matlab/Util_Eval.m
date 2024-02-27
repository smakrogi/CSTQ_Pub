%% Very Important
fclose all;close all; clear all; clc;

if ispc
    user_folder = getenv('USERPROFILE');
    data_work_folder = fullfile(user_folder,'Documents','code','1data-lab','CSTQ','2Modify');
    code_work_folder = fileparts(which('README.md'));
elseif ismac
    user_folder = getenv('HOME');
    data_work_folder = fullfile(user_folder,'Documents','code','1data-lab','CSTQ','2Modify');
    code_work_folder = fileparts(which('README.md'));
else
    user_folder = getenv('HOME');
    data_work_folder = fullfile(user_folder,'code','1data-lab','CSTQ','2Modify');
    code_work_folder = fileparts(which('README.md'));
end

Param_Excel_Path = 'Parameters.xlsx';          % on current folder

DatasetNames      = Data_Names;
data_nb           = menu('Dataset name:', DatasetNames);
dataset_name      = DatasetNames{data_nb};   % SIM1(1)   MSC1(7)  GOWT1(11)  Hela1(9) 'e.g. Fluo-N2DH-SIM\03';

sequence_name=dataset_name(1:end-3);
sequence_num=dataset_name(end-1:end);
Nom  = strcat(sequence_name,sequence_num); %'e.g. Fluo-N2DH-SIM02';

%Write output excel
t_date=Util_DateFormat;
autoTuningExcel=strcat('AutoTuningResult-',t_date,'.xlsx');
%file name
auto_excel_full_name=strcat(fullfile(data_work_folder,sequence_name),filesep,autoTuningExcel);
%not exist
if exist(auto_excel_full_name) ~=2
    header     = {'Dataset name' 'Frame_Modulo' 'CLAHE_tile_num' 'CLAHE_clip_lim' 'ST_Diff_Type' 'Lambda_Tempo' 'TS_Ratio' 'ST_Diff_Iter' 	'Kappa' 'WSEG_ID' 'Parzen Sigma' 'ImHMin' 'CDF_Thres' 'LS_ID' 'LS_Iter' 'LS_mu' 'ImHMin_SDT' 'Mot_Act_Meas_ID' 	'FB_ID' 'FB_Sigma' 'Mask_Folder_Name' 'DET' 'SEG' 'Mean Dice' 'Mean Jaccard'};
    writecell(header,auto_excel_full_name,'WriteMode','append');
end

t_date=Util_DateFormat;
log_name=strcat(t_date,'-',sequence_name,'.log');
%get mean dice and mean jaccard

dice_jaccard_name = strcat('ST_Diff_TCV ',Nom,'.xlsx');
%mean_dice_jaccard=Get_Mean_dice_jaccard(dice_jaccard_name);
mean_dice_jaccard={0,0};
% Analysis of Results

[~, ~, DatasetExcelNames] = xlsread(Param_Excel_Path, 1, 'A2:A32');

if ismac
    DatasetExcelNames = strrep(DatasetExcelNames,'\','/');
elseif isunix
    DatasetExcelNames = strrep(DatasetExcelNames,'\','/');
elseif ispc
    % Code to run on Windows platform
else
    disp('Platform not supported')
end

disp('First, Very Important to locate the matlab root directory to \Cell_Segm_Track_Quant_MIVIC')
disp('Very Important to locate the Evaluation Software directory')

trial_params= Get_All_Parameters(Param_Excel_Path, data_nb);
%EvalAuto_ByLine(code_work_folder,data_work_folder,log_name,trial_params,dataset_name,auto_excel_full_name,mean_dice_jaccard,0);
EvalAuto_ByLine(code_work_folder,data_work_folder,log_name,trial_params,dataset_name,auto_excel_full_name,mean_dice_jaccard,1);