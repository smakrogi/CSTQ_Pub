function [OrigIm, Nb_Orig, number_of_digits] = Get_Original_Images(Im_Folder)
% input parameter: directory where the Binary masks are
% output : a structure array containing the Binary_Masks and the number of masks in the Folder
% S. Makrogiannis, MIVIC, PEMACS, DESU <smakrogiannis@desu.edu>

Images = dir( fullfile(Im_Folder,'*.tif*') );   % list all *.tif files
Orig_Image_Names = {Images.name}; % file names
% cell array to store all images.
% Define the cell array with the right size
Nb_Orig=numel(Orig_Image_Names);
OrigIm=cell(Nb_Orig,1);
NumericIndices = zeros(1, Nb_Orig);

for i = 1 : Nb_Orig
    % File parts of the masks
    [~, name , ~]     = fileparts(Orig_Image_Names{i});
    % Get the frame number from the masks names substring.
    name              = name(2:end);  % numeric part
    % Convert mask number substring to Masks_Names and store to vector.
    NumericIndices(i) = str2double(name);
end

% Sort numeric array. Get indices after sorting.
[~, SortedIndices]    = sort(NumericIndices, 'ascend');

for k=1:Nb_Orig
    %  For masks: Take the sorted index for frame #k.
    % store each image into a different cell
    Image_Name  = Orig_Image_Names{SortedIndices(k)};
    OrigIm{k}=double(imread(strcat(Im_Folder,filesep,Image_Name)));   
end

number_of_digits = numel(cell2mat(regexp('t000.tif','\d+','match')));

end
