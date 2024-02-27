function Util_Write_Exp_Params(exp_parameters, dataset_name,data_work_folder,sequence_name,experiment_params)

%file name
exp_parameters_full_name=strcat(fullfile(data_work_folder,sequence_name),filesep,exp_parameters);
%not exist
if exist(exp_parameters_full_name) ~=2
    header     = {'Dataset name' 'Frame_Modulo' 'Noise_Filter_Type' 'CLAHE_tile_num' 'CLAHE_clip_lim' 'ST_Diff_Type' 'Lambda_Tempo' 'TS_Ratio' 'ST_Diff_Iter' 	'Kappa' 'WSEG_ID' 'Parzen Sigma' 'ImHMin' 'CDF_Thres' 'LS_ID' 'LS_Iter' 'LS_mu' 'ImHMin_SDT' 'Mot_Act_Meas_ID' 	'FB_ID' 'FB_Sigma' 'Mask_Folder_Name'};
    writecell(header,exp_parameters_full_name,'WriteMode','append');
else
    delete(exp_parameters_full_name);
    header     = {'Dataset name' 'Frame_Modulo' 'Noise_Filter_Type' 'CLAHE_tile_num' 'CLAHE_clip_lim' 'ST_Diff_Type' 'Lambda_Tempo' 'TS_Ratio' 'ST_Diff_Iter' 	'Kappa' 'WSEG_ID' 'Parzen Sigma' 'ImHMin' 'CDF_Thres' 'LS_ID' 'LS_Iter' 'LS_mu' 'ImHMin_SDT' 'Mot_Act_Meas_ID' 	'FB_ID' 'FB_Sigma' 'Mask_Folder_Name'};
    writecell(header,exp_parameters_full_name,'WriteMode','append');
end

disp('Wite All Parameters to Files');
% total row number
total_rows=numel(experiment_params);
% total col number
total_cols=numel(header);
% result cell
result_cell=cell(total_rows,total_cols);
for index_row=1:total_rows
    % read one trial parameter from experiment parameters list
    result_array=split(experiment_params{index_row},{' '});
    
    % remove "" string 
    result_array = result_array(~cellfun(@isempty, result_array))
    
    % num_array has 19 parameters
    num_array=ceil(str2double(result_array));
    % struct to cell
    % cell_temp has 20 parameters the last one is ''
    cell_temp=struct2cell(SetParameters_V29_02(num_array));

    %Transpose
    current_params_cell=cell_temp';
    % data
    Temp_array=[dataset_name,current_params_cell];
    [m,n]=size(Temp_array);
    for index_col=1:n
        result_cell{index_row,index_col} =Temp_array{1,index_col};
    end

    if mod(index_row,300)==0
        fprintf('finised %f%\n',100*index_row/total_rows);
    end
end


%save data
writecell(result_cell,exp_parameters_full_name,'WriteMode','append');
end