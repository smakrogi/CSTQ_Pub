function [Reference_data,  Reference_Num,Nb_Ref_Images] = Get_Some_References(dir_Reference_Images)  
% input parameter: directory where the Reference images
% output : a structure array containing the Reference images and array of associated filename numbers 
Images = dir( fullfile(dir_Reference_Images,'*.tif') );   % list all *.tif files
Reference_Image_Names = {Images.name}; % file names
% cell array to store all images. 
% Define the cell array with the right size
Nb_Ref_Images=numel(Reference_Image_Names);
threshold=1;
Ref_Num=zeros(Nb_Ref_Images,1);
Ref_data=cell(Nb_Ref_Images,1);
for i=1:Nb_Ref_Images
    Image_Name = Reference_Image_Names{i};
    
    [~, name , ~]=fileparts(Image_Name);
    
    G=str2double(name(end-2:end));
    Ref_Num(i)=G;
    % store each image into a different cell
    Ref_data{i}=double(imread(strcat(dir_Reference_Images,filesep,Image_Name))>=threshold);       % read the image each image is defined by: Referenceing_Data{i}
end
% affectatio\
Reference_data =Ref_data;
Reference_Num=Ref_Num;







