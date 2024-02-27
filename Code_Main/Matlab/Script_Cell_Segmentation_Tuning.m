% Script for cell tracking using segmentation masks for a single sequence
% S Makrogiannis, MIVIC, PEMACS, DESU <smakrogiannis@desuedu>
% J Zhao, MIVIC member
% SEGmentation and Tracking Auto Tuning Code



%Step 1: Auto Generate Parameters Excel

%[exp_parameters_full_name,experiment_params_size]= Run_AutoGenParams_v29_02();

%Step 2: Auto Tuning based on Excel Parameters

exp_parameters_full_name="Parameters-custom.xlsx";
experiment_params_size=6;

Tuning_Seg_Track_v29_02(exp_parameters_full_name,experiment_params_size);



