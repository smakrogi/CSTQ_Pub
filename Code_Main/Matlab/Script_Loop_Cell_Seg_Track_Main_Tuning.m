% Script for cell tracking using segmentation masks for a single sequence
% S Makrogiannis, MIVIC, PEMACS, DESU <smakrogiannis@desuedu>
% J Zhao, MIVIC member
% SEGmentation and Tracking Auto Tuning Code

fclose all;close all; clear all; clc;

%Step 1: Auto Generate Parameters Excel

%[exp_parameters_full_name,experiment_params_size]= Run_AutoGenParams_v29_02();

%Step 2: Auto Tuning based on Excel Parameters

%result_directory = Tuning_Seg_Track_v29_02(exp_parameters_full_name,experiment_params_size);
Tuning_Seg_Track_v29_02("Challenge_Parameters.xlsx",14);


