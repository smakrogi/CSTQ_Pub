function [Bin_Masks,Nb_Masks] = Get_Binary_Masks(Mask_Folder)  
% input parameter: directory where the Binary masks are
% output : a structure array containing the Binary_Masks and the number of masks in the Folder 
Images = dir( fullfile(Mask_Folder,'*.tif*') );   % list all *.tif files
Masks_Names = {Images.name}; % file names
% cell array to store all images. 
% Define the cell array with the right size
Nb_Masks=numel(Masks_Names);
Bin_Masks=cell(Nb_Masks,1);
NumericIndices = zeros(1, Nb_Masks);
 for i = 1 : Nb_Masks
        % File parts of the masks
        [~, name , ~]     = fileparts(Masks_Names{i});
        % Get the frame number from the masks names substring.
        frame_number_position = regexp(name, '\d', 'once');
        name              = name(frame_number_position:end);  % numeric part 
        % Convert mask number substring to Masks_Names and store to vector.
        NumericIndices(i) = str2num(name);
    end
 % Sort numeric array. Get indices after sorting.
    [~, SortedIndices]    = sort(NumericIndices, 'ascend');

   for k=1:Nb_Masks
        %  For masks: Take the sorted index for frame #k.
        % store each image into a different cell
        Mask_Name  = Masks_Names{SortedIndices(k)};
        Bin_Masks{k}=double(imread(strcat(Mask_Folder,filesep,Mask_Name)));   
   end
end


