function Params = Get_All_Parameters(workbook_file,data_nb)
% Get parameters from the excel file where we init the experimentally found
% parameters Can be called using one parameters only name excel file here
%  [SigmaofParzen,Lambda_Tempo,TS_Ratio,Threshold_or_Factor,Mask_Folder_Name]
%   = Get_All_Parameters('Parameters.xlsx'); reads data from the first worksheet in the Microsoft
%   Excel spreadsheet file named FILE and returns the data as column vectors.

%% Input handling

% % If no sheet is specified, read first sheet
% if nargin == 2 || isempty(sheet_name)
%     sheet_name = 1;
% end
% % If row start and end points are not specified, define defaults
% if nargin <= 4
%     start_row = 1;
%     end_row = 26;
% end

%% Import the data
% [~, ~, raw] = xlsread(workbook_file, sheet_name, sprintf('B%d:V%d',start_row(1),end_row(1)));
% for block=2:length(start_row)
%     [~, ~, tmpRawBlock] = xlsread(workbook_file, sheet_name, sprintf('B%d:V%d',start_row(block),end_row(block)));
%     raw = [raw;tmpRawBlock]; %#ok<AGROW>
% end
% raw(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),raw)) = {''};
% cellVectors = raw(:,end);
% raw = raw(:,1:end-1);
% 
% %% Create output variable
% data = reshape([raw{:}],size(raw));
% 
% %% Allocate imported array to column variable names
% Params.Frame_Modulo = data(data_nb,1);
% Params.Noise_Filter_Type = data(data_nb,2);
% Params.CLAHE_tile_num = data(data_nb,3);
% Params.CLAHE_clip_lim = data(data_nb,4);
% Params.ST_Diff_Type = data(data_nb,5);
% Params.Lambda_Tempo = data(data_nb,6);
% Params.TS_Ratio = data(data_nb,7);
% Params.ST_Diff_Iter = data(data_nb,8);
% Params.Kappa = data(data_nb,9);
% Params.WSEG_ID = data(data_nb,10);
% Params.ParzenSigma = data(data_nb,11);
% Params.ImHMin = data(data_nb,12);
% Params.CDF_Thres = data(data_nb,13);
% Params.LS_ID = data(data_nb,14);
% Params.LS_Iter = data(data_nb,15);
% Params.LS_mu = data(data_nb,16);
% Params.ImHMin_SDT = data(data_nb,17); 
% Params.Mot_Act_Meas_ID = data(data_nb,18);
% Params.FB_ID = data(data_nb,19);
% Params.FB_Sigma = data(data_nb,20);
% Params.Mask_Folder_Name = cellVectors{data_nb};

Parameter_Table = readtable(workbook_file,'VariableNamingRule','preserve');
Params.Frame_Modulo = Parameter_Table.Frame_Modulo(data_nb);
Params.Noise_Filter_Type = Parameter_Table.Noise_Filter_Type(data_nb);
Params.CLAHE_tile_num = Parameter_Table.CLAHE_tile_num(data_nb);
Params.CLAHE_clip_lim = Parameter_Table.CLAHE_clip_lim(data_nb);
Params.ST_Diff_Type = Parameter_Table.ST_Diff_Type(data_nb);
Params.Lambda_Tempo = Parameter_Table.Lambda_Tempo(data_nb);
Params.TS_Ratio = Parameter_Table.TS_Ratio(data_nb);
Params.ST_Diff_Iter = Parameter_Table.ST_Diff_Iter(data_nb);
Params.Kappa = Parameter_Table.Kappa(data_nb);
Params.WSEG_ID = Parameter_Table.WSEG_ID(data_nb);
Params.ParzenSigma = Parameter_Table.Parzen_Sigma(data_nb);
Params.ImHMin = Parameter_Table.ImHMin(data_nb);
Params.CDF_Thres = Parameter_Table.CDF_Thres(data_nb);
Params.LS_ID = Parameter_Table.LS_ID(data_nb);
Params.LS_Iter = Parameter_Table.LS_Iter(data_nb);
Params.LS_mu = Parameter_Table.LS_mu(data_nb);
Params.ImHMin_SDT = Parameter_Table.ImHMin_SDT(data_nb);
Params.Mot_Act_Meas_ID = Parameter_Table.Mot_Act_Meas_ID(data_nb);
Params.FB_ID = Parameter_Table.FB_ID(data_nb);
Params.FB_Sigma = Parameter_Table.FB_Sigma(data_nb);

