function current_params=SetParameters(num_array)
% get paramets arrage
Params_Arrange=Util_Get_Params_Arrange;

%set current parameter
current_params.Frame_Modulo = Params_Arrange.Frame_Modulo(num_array(1));
current_params.CLAHE_tile_num = Params_Arrange.CLAHE_tile_num(num_array(2));
current_params.CLAHE_clip_lim = Params_Arrange.CLAHE_clip_lim(num_array(3));
current_params.ST_Diff_Type = Params_Arrange.ST_Diff_Type(num_array(4));
current_params.Lambda_Tempo = Params_Arrange.Lambda_Tempo(num_array(5));
current_params.TS_Ratio = Params_Arrange.TS_Ratio(num_array(6));
current_params.ST_Diff_Iter = Params_Arrange.ST_Diff_Iter(num_array(7));
current_params.Kappa = Params_Arrange.Kappa(num_array(8));
current_params.WSEG_ID = Params_Arrange.WSEG_ID(num_array(9));
current_params.ParzenSigma = Params_Arrange.ParzenSigma(num_array(10));
current_params.ImHMin = Params_Arrange.ImHMin(num_array(11));
current_params.CDF_Thres = Params_Arrange.CDF_Thres(num_array(12));
current_params.LS_ID = Params_Arrange.LS_ID(num_array(13));
current_params.LS_Iter = Params_Arrange.LS_Iter(num_array(14));
current_params.LS_mu = Params_Arrange.LS_mu(num_array(15));
current_params.ImHMin_SDT = Params_Arrange.ImHMin_SDT(num_array(16));
current_params.Mot_Act_Meas_ID = Params_Arrange.Mot_Act_Meas_ID(num_array(17));
current_params.FB_ID = Params_Arrange.FB_ID(num_array(18));
current_params.FB_Sigma = Params_Arrange.FB_Sigma(num_array(19));
current_params.Mask_Folder_Name='';

%disp current parameter
disp(current_params);