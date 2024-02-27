function [fid, cell_data] = Util_runDetSegTrackCMD(data_work_folder, sequence_name, code_work_folder, sequence_num, full_log_name, isRunTRA)

file_tra=strcat(fullfile(data_work_folder, sequence_name), filesep, sequence_num, '_RES',filesep,'res_track.txt')

if(ispc)

command = strcat("cmd /C del /f ",strcat(fullfile(data_work_folder,sequence_name),filesep,'*.log'));
[status,cmdout] = system(command)

full_eval_DET=strcat(fullfile(code_work_folder,'EvaluationSoftware','Win'),filesep,"DETMeasure.exe");
full_eval_SEG=strcat(fullfile(code_work_folder,'EvaluationSoftware','Win'),filesep,"SEGMeasure.exe");
full_eval_TRA=strcat(fullfile(code_work_folder,'EvaluationSoftware','Win'),filesep,'TRAMeasure.exe');


fprintf("file_tra : %s\n",file_tra);
%warning('off','all')


command=strcat("cmd /C ",full_eval_DET," ",data_work_folder,filesep,sequence_name," ",sequence_num," 3 >> ", full_log_name)
[status,cmdout] = system(command);
command=strcat("cmd /C ",full_eval_SEG," ",data_work_folder,filesep,sequence_name," ",sequence_num," 3 >> ", full_log_name)
[status,cmdout] = system(command)
%if isRunTRA==1

if exist(file_tra, 'file') == 2
    command=strcat("cmd /C ",full_eval_TRA," ",data_work_folder,filesep,sequence_name," ",sequence_num," 3 >> ", full_log_name)
    [status,cmdout] = system(command,'-echo');
    % auto close eror Message Box
    % m = findall(0,'type','figure','tag','Msgbox_ ');
    % delete(m);
end

% Linux or Mac
else
command = strcat("rm -rf ",strcat(fullfile(data_work_folder,sequence_name),filesep,'*.log'));
%[status,cmdout] = system(command)
[status,cmdout] = unix(command)

full_eval_DET=strcat(fullfile(code_work_folder,'EvaluationSoftware','Linux'),filesep,"DETMeasure");
full_eval_SEG=strcat(fullfile(code_work_folder,'EvaluationSoftware','Linux'),filesep,"SEGMeasure");
full_eval_TRA=strcat(fullfile(code_work_folder,'EvaluationSoftware','Linux'),filesep,'TRAMeasure');

if ismac
    full_eval_DET=strcat(fullfile(code_work_folder,'EvaluationSoftware','Mac'),filesep,"DETMeasure");
    full_eval_SEG=strcat(fullfile(code_work_folder,'EvaluationSoftware','Mac'),filesep,"SEGMeasure");
    full_eval_TRA=strcat(fullfile(code_work_folder,'EvaluationSoftware','Mac'),filesep,'TRAMeasure');
end
command=strcat(" ",full_eval_DET," ",data_work_folder,filesep,sequence_name," ",sequence_num," 3 >> ", full_log_name)
%[status,cmdout] = system(command)
[status,cmdout] = unix(command)

command=strcat(" ",full_eval_SEG," ",data_work_folder,filesep,sequence_name," ",sequence_num," 3 >> ", full_log_name)
%[status,cmdout] = system(command)
[status,cmdout] = unix(command)
if exist(file_tra, 'file') == 2
    command=strcat(" ",full_eval_TRA," ",data_work_folder,filesep,sequence_name," ",sequence_num," 3 >> ", full_log_name);
    %[status,cmdout] = system(command)
    [status,cmdout] = unix(command)

end
end

%command = 'cmd /C C:\Users\jzhao\Documents\GitHub\MakLab-62-CSTQ-Debug-Modify\autotuning.bat';
disp("Wait for the evaluatin 5 seconds ");
pause(5);

%fid = fopen(full_log_name,'r')
if exist(full_log_name)==2
fid = fopen(full_log_name,'r'); % open exist file and append contents
else
fid = fopen(full_log_name,'w'); % create file and write to it
end


if(fid ==-1)
disp('Error to Read log file, Check the Path, Add the Path to Project');
else
rows=0;

%header = { 'Name', 'Score'}
%header ={'score'};
max_DET=0;
max_SEG=0;
max_TRA=0;
while(~feof(fid) && rows<3)
    % Execute till EOF has been reached
    rows= rows+1;
    curentLine = fgetl(fid);                             % Read the file line-by-line and store the content

    if(isempty(curentLine)~=1 && contains(curentLine,'measure: '))

        %cell_data{rows} = roundn(str2num( extractAfter( curentLine,"measure: ")),-8);
        cell_data{rows} = extractAfter( curentLine,"measure: ");

        num_score=roundn(str2num( extractAfter( curentLine,"measure: ")),-8);
        if(rows==1 && num_score>max_DET)
            max_DET=num_score;
        elseif (rows==2 && num_score>max_SEG)
            max_SEG=num_score;
        elseif (rows==3 && num_score>max_TRA)
            max_TRA=num_score;
        end

    else
        cell_data{rows} =  curentLine;
    end

end
disp("Now The Max Scores are as Following:")
disp(sprintf('Max DET:%.8f ; SEG:%.8f  ; TRA:%.8f',max_DET,max_SEG,max_TRA));
end

%make the cell_data size = 3 to write to output file
[cell_r,cell_c]=size(cell_data);
if cell_c<2
cell_data{2}=0
cell_data{3}=0
elseif cell_c<3
cell_data{3}=0
end
disp(cell_data);
end