function  EvalAuto_ByLine(code_work_folder,data_work_folder,log_name,trial_params,dataset_name,auto_excel_full_name,mean_dice_jaccard,isRunTRA, isRunST)

disp('code_work_folder');
disp(code_work_folder)
disp('data_work_folder');
disp(data_work_folder)
stringToBeFound='measure: 0.';
sequence_name=dataset_name(1:end-3);
sequence_num=dataset_name(end-1:end);
full_log_name=strcat(fullfile(data_work_folder,sequence_name),filesep,log_name);

%command = 'cmd /C C:\Users\jzhao\Documents\GitHub\MakLab-062-CSTQ-Auto-Tunning\Code_Main\Matlab\Auto-Fluo-C2DL-Huh7-02.bat';

%save trial parameters
cell_params=struct2cell(trial_params)';

% run GT CMD
[fidGT, cell_data_GT] = Util_runDetSegTrackCMD(data_work_folder, sequence_name, code_work_folder, sequence_num, full_log_name, isRunTRA);
% Close the file
fclose(fidGT);

% 0 not run ST
if isRunST==0
    %save all column
    autoTuning_Results_Cell=[dataset_name,cell_params,cell_data_GT,mean_dice_jaccard];
else
    % run ST CMD
    [fidST, cell_data_ST] = Util_runDetSegTrackCMD(data_work_folder, sequence_name, code_work_folder, sequence_num, full_log_name, isRunTRA);
    % Close the file
    fclose(fidST);
    %save all column
    autoTuning_Results_Cell=[dataset_name,cell_params,cell_data_GT,cell_data_ST,mean_dice_jaccard];
end




%save data
writecell(autoTuning_Results_Cell,auto_excel_full_name,'WriteMode','append');


fclose('all');
close all;
