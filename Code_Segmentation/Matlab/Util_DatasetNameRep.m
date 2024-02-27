function dataset_name=Util_DatasetNameRep(dataset_name_set)
dataset_name=dataset_name_set;
    if ismac
        dataset_name = strrep(dataset_name,'\','/');
    elseif isunix
        dataset_name = strrep(dataset_name,'\','/');
        disp('linux platform');
    elseif ispc
        % Code to run on Windows platform
        disp('windowns platform');
    else
        disp('Platform not supported')
    end
end