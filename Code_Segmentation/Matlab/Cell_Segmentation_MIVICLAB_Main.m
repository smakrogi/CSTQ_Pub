function Segmentation_Results_Cell = Cell_Segmentation_MIVICLAB_Main(workFolder, ...
    dataset_name, param_excel_path, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Main function for live cell segmentation in an image sequence.     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% F. Boukari, MIVIC, PEMACS, DESU
% S. Makrogiannis, MIVIC, PEMACS, DESU <smakrogiannis@desu.edu>
% syntax: Segmentation_Results_Cell =
% Cell_Segmentation_MIVICLAB_Main(workFolder, dataset_name, Param_Excel_Path);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Call function to import Parameters for each dataset from Excel                           %
% The spreadsheet Parameters.xlsx contains algorithm parameter values for each sequence     %
% Use the spreadsheet to tune the parameters.                                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% If number of parameters is equal to 3, use spreadsheet params. Otherwise,
% use params passed from auto-tuning.
if nargin == 3
    Parameter_Table = readtable(param_excel_path,'VariableNamingRule','preserve');
    DatasetExcelNames = Parameter_Table.Dataset_Name(1:26);
elseif nargin == 4
else
    error('Incorrect number of input arguments. Exiting.');
end

if ismac
    DatasetExcelNames = strrep(DatasetExcelNames,'\','/');
elseif isunix
    DatasetExcelNames = strrep(DatasetExcelNames,'\','/');
elseif ispc
    % Code to run on Windows platform
else
    error('Platform not supported. Exiting.');
end

%%

flag = 0;
ii = 0;
while flag == 0 && ii < length(DatasetExcelNames)
    ii = ii + 1;
    flag = strcmpi(DatasetExcelNames{ii}, dataset_name);
end
if flag==1
    data_nb = ii;
    fprintf([dataset_name, ' sequence found, continuing.\n']);
else
    error([dataset_name, ' sequence not found. Exiting.']);
end

if nargin == 3
    Params = Get_All_Parameters(param_excel_path, data_nb);
elseif nargin == 4
    Params=varargin{1};
else
    error('Incorrect number of input arguments. Exiting.');
end

if ismac
    Params.binary_folder = '~/Documents/Codes/gitrepos/Cell_Segm_Track_Quant_MIVIC/Code_CTC/Mac';
elseif isunix
    Params.binary_folder = '~/Documents/Codes/gitrepos/Cell_Segm_Track_Quant_MIVIC/Code_CTC/Linux';
elseif ispc
    % Code to run on Windows platform
    user_folder = getenv('USERPROFILE');
    Params.binary_folder = fullfile(user_folder, 'Documents','Codes','src','gitrepos','Cell_Segm_Track_Quant_MIVIC', ...
        'Code_CTC', 'Win');
else
    error('Platform not supported. Exiting.');
end

All_Noise_Filter_Types = {'median_filtering_only' , 'median_filtering_and_BM3D', 'BM3D_only', 'autoencoder'};
Params.noise_filter_type = All_Noise_Filter_Types{Params.Noise_Filter_Type};

All_Mot_Activ_Crit_Types = Motion_Activity_Criteria_Names;
Params.motion_activity_measure = All_Mot_Activ_Crit_Types{Params.Mot_Act_Meas_ID};
% Motion activity cases: {'original','diffused','st_gradient',...
%     'regions_diffused','regions_st_gradient', 'regions_active_pixels', ...
%     'regions_st_laplace','regions_st_moments','regions_st_hessian' , ...
%   'regions_sp_hessian_tempo_deriv'}

All_Level_Set_Types = {'chan_vese','lse_bfe'};
Params.level_set_type = All_Level_Set_Types{Params.LS_ID}; % {'chan_vese','lse_bfe'}

All_Fgnd_Bkgnd_Types = {'cdf_mam', 'cdf_joint', 'normal_pdf_joint', 'kde_pdf_joint', 'classifier'};
Params.fgnd_bgnd_method = All_Fgnd_Bkgnd_Types{Params.FB_ID};
% options: {'cdf_mam', 'cdf_joint', 'normal_pdf_joint', 'kde_pdf_joint'}

All_Wat_Input_Types = {'diff_frame_and_edge_min','diff_frame_and_feat_map_max',...
    'diff_frame_and_edge_map_and_feat_map','flat_diff_frame_and_edge_map_and_feat_map', ...
    'feat_map_and_edge_min', 'feat_map_and_feat_map_max', 'feat_map_and_edge_map_and_feat_map'};
Params.water_seg_input = All_Wat_Input_Types{Params.WSEG_ID};

% Auxilliary parameter settings.
Params.compute_seg_measure  = false;
Params.display              = true;  % create figures or not.
Params.thresh_solidity      = 0.9; % 0.8926;   %SIM04  thres =0.8926 smallest other .95, 0.9 for Hela2
Params.hist_train_nb_frames = 10;
Params.training_mode        = false;
Params.tuning               = false;

disp(Params);

% Call segmentation for all franes.
if Params.tuning == true
    Params.display = false;

    % Perform optimization.
    Params.CLAHE_clip_lim_range = [1e-4, 0.75];
    Params.TS_Ratio_range = [1, 150];
    Params.ST_Diff_Iter_range = [10, 70];
    Params.ParzenSigma_range = [2, 80];
    Params.LS_Iter_range = [0, 100];

    x_opt = OptimizeCSTQParameters(data_nb, workFolder, ...
        dataset_name, Params);

    Params.CLAHE_clip_lim = x_opt(1);
    Params.TS_Ratio = x_opt(2);
    Params.ST_Diff_Iter = x_opt(3);
    Params.ParzenSigma = x_opt(4);
    Params.LS_Iter = x_opt(5);

    Segmentation_Results_Cell = ...
        Cell_Segmentation_All_Frames(data_nb, workFolder,...
        dataset_name, Params);
else

    Segmentation_Results_Cell = ...
        Cell_Segmentation_All_Frames(data_nb, workFolder,...
        dataset_name, Params);
end

end


