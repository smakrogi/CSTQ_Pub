function DisplayFrameSequence(image_path)

%%  Read data.
Images = dir( fullfile(image_path,'*.tif') );   % list all *.tif files
image_names = {Images.name}; % file names

% Number of training images
nb_images = numel(image_names);
All_Images = cell(numel(image_names),1);
for ii = 1:nb_images
    image_name = image_names{ii};
    [temp_image, map] = imread(strcat(image_path,filesep,image_name));
    if ii==1
        image_size = size(temp_image);
        image_class = class(temp_image);
        All_Images = zeros([image_size, nb_images], image_class);
    end
    All_Images(:,:,ii) = temp_image;
end

int_max = max(double(All_Images(:)));
All_Images = double(All_Images)/int_max;
figure, montage(All_Images, 'BorderSize', 10); colormap('parula');
implay(All_Images, 1);

end