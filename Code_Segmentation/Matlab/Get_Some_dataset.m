function [Training_data, Reference_data, Train_Numeros, Ref_Numeros, Nb_Ref, Nb_Train_Images] = ...
    Get_Some_dataset(workFolder,dataset_name)
dir_Training_Images=fullfile(workFolder,dataset_name);
dir_Reference_Images=fullfile(workFolder,strcat(dataset_name,'_ST',filesep,'SEG'));

%%  Read the Training data
Images = dir( fullfile(dir_Training_Images,'*.tif') );   % list all *.tif files
Train_Image_Names = {Images.name}; % file names
% cell array to store all images.
% Number of training images
Nb_Train_Images = numel(Train_Image_Names);
Training_data = cell(numel(Train_Image_Names),1);
Train_Numeros = zeros(Nb_Train_Images,1);
for i = 1:Nb_Train_Images
    Image_Name = Train_Image_Names{i};
    % Get numbers if file name
    [~, name , ~] = fileparts(Image_Name);
    Train_Numeros(i) = str2double(name(end-2:end));  % fichier numero du nom du fichier
    % store each image into a different cell
    Training_data{i} = imread(strcat(dir_Training_Images,filesep,Image_Name));
    % read the image each image is defined by: Training_Data{i}
end

%% Read all the Reference data
[Reference_data, Ref_Numeros, Nb_Ref] = Get_Some_References(dir_Reference_Images);
% Get_References : function input parameter: numel(Train_Image_Names )which is Nb_Train_Images ,dir_ReferenceImages: directory where the Reference truth images
% output : a structure array containing the Reference truth images
