function Params = Get_All_Parameters(workbookFile,Data_Nb,sheetName,startRow,endRow)
% Get parameters from the excel file where we init the experimentally found
% parameters Can be called using one parameters only name excel file here
%  [SigmaofParzen,Lambda_Tempo,TS_Ratio,Threshold_or_Factor,Mask_Folder_Name]
%   = Get_All_Parameters('Parameters.xlsx'); reads data from the first worksheet in the Microsoft
%   Excel spreadsheet file named FILE and returns the data as column vectors.

%% Input handling

% If no sheet is specified, read first sheet
if nargin == 2 || isempty(sheetName)
    sheetName = 1;
end
% If row start and end points are not specified, define defaults
if nargin <= 4
    startRow = 2;
    % modified 11/01/2022
    endRow = 27;
end

%% Import the data
[~, ~, raw] = xlsread(workbookFile, sheetName, sprintf('B%d:V%d',startRow(1),endRow(1)));
for block=2:length(startRow)
    [~, ~, tmpRawBlock] = xlsread(workbookFile, sheetName, sprintf('B%d:V%d',startRow(block),endRow(block)));
    raw = [raw;tmpRawBlock]; %#ok<AGROW>
end
raw(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),raw)) = {''};
cellVectors = raw(:,end);
raw = raw(:,1:end-1);

%% Create output variable
data = reshape([raw{:}],size(raw));

%% Allocate imported array to column variable names
Params.Frame_Modulo = data(Data_Nb,1);
Params.Noise_Filter_Type = data(Data_Nb,2);
Params.CLAHE_tile_num = data(Data_Nb,3);
Params.CLAHE_clip_lim = data(Data_Nb,4);
Params.ST_Diff_Type = data(Data_Nb,5);
Params.Lambda_Tempo = data(Data_Nb,6);
Params.TS_Ratio = data(Data_Nb,7);
Params.ST_Diff_Iter = data(Data_Nb,8);
Params.Kappa = data(Data_Nb,9);
Params.WSEG_ID = data(Data_Nb,10);
Params.ParzenSigma = data(Data_Nb,11);
Params.ImHMin = data(Data_Nb,12);
Params.CDF_Thres = data(Data_Nb,13);
Params.LS_ID = data(Data_Nb,14);
Params.LS_Iter = data(Data_Nb,15);
Params.LS_mu = data(Data_Nb,16);
Params.ImHMin_SDT = data(Data_Nb,17); 
Params.Mot_Act_Meas_ID = data(Data_Nb,18);
Params.FB_ID = data(Data_Nb,19);
Params.FB_Sigma = data(Data_Nb,20);
Params.Mask_Folder_Name = cellVectors{Data_Nb};
