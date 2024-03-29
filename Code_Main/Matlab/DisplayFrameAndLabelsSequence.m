function DisplayFrameAndLabelsSequence(image_path, data_string)

%%  Read data.
label_path = [image_path, data_string];
Images = dir( fullfile(image_path,'*.tif') );   % list all *.tif files
Label_Maps = dir( fullfile(label_path, '*.tif') );   % list all *.tif files
image_names = {Images.name}; % file names
label_map_names = {Label_Maps.name};

% Number of training images
nb_images = numel(image_names);
All_Images = cell(numel(image_names),1);
for ii = 1:nb_images
    image_name = image_names{ii};
    label_map_name = label_map_names{ii};
    temp_image = imread(strcat(image_path,filesep,image_name));
    image_max = double(max(temp_image(:)));
    if image_max > 256
        temp_image = 256 * double(temp_image) / image_max;
        temp_image = uint8(temp_image);
    end
    temp_label_map = imread(strcat(label_path,filesep,label_map_name));
    label_max = double(max(temp_label_map(:)));
    if label_max > 256
        temp_label_map = 256 * double(temp_label_map) / label_max;
        temp_label_map = uint8(temp_label_map);
    end
    image_class = 'uint8'; % class(temp_image);
    if ii==1
        image_size = size(temp_image);
        All_Images = zeros([image_size, 3, nb_images], image_class);
    end
    All_Images(:,:,:,ii) = labeloverlay(temp_image, temp_label_map, 'Transparency', .75);
end

% int_max = max(double(All_Images(:)));
% All_Images = double(All_Images)/int_max;
figure, montage(All_Images, 'BorderSize', 10); colormap('parula');
implay(All_Images, 1);

end