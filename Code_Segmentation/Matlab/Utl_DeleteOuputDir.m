function Util_DeleteDir(data_work_folder,dataset_name)
    sequence_number=dataset_name(end-1:end);
    % Get Old Reference Diretory
    %old_mask=strcat(fullfile(data_work_folder,dataset_name(1:end-3),dataset_name(end-1:end)),'_Msk_CSTQ');
    
    old_mask=fullfile(data_work_folder,dataset_name(1:end-3),[sequence_number,'_Msk_CSTQ'])+""
    if exist(old_mask,'dir')
        delete(strcat(old_mask+filesep+'*'));
        %rmdir(old_mask);
    end
    %old_res=strcat(fullfile(data_work_folder,dataset_name(1:end-3),dataset_name(end-1:end)),'_Res');
    old_res=fullfile(data_work_folder,dataset_name(1:end-3),[sequence_number,'_Res'])+""
    if exist(old_res,'dir')
        %rmdir(old_res);
        delete(strcat(old_res+filesep+'*.*'));
    
    end

end