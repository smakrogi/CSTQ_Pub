function [isOK,err_msg]=Util_CheckEachFolderExist(data_work_folder,code_work_folder,eval_folder)
    isOK=1;
    eval_folder_win=fullfile(code_work_folder,'EvaluationSoftware','Win');
    eval_folder_linux=fullfile(code_work_folder,'EvaluationSoftware','Linux');
    err_msg='Directory Detection Passed';
    if exist(data_work_folder)~=7
        err_msg='data dir not exist';
        isOK=0
    elseif exist(code_work_folder)~=7
        err_msg='code_work_folder not exist';
        isOK=0
    elseif exist(eval_folder_linux)~=7
        err_msg='EvaluationSoftware Linux folder not exist';
        isOK=0
    elseif exist(eval_folder_win)~=7
        err_msg='EvaluationSoftware Win folder not exist';
        isOK=0
    end
end