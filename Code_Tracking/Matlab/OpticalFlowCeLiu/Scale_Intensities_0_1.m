function image = Scale_Intensities_0_1(image)
% rescales an input image into K range for 8 bits image K=255 
% gives [0,255] range using equation 2.6.10 & eq 2.6.11 page 80
image=double(image);
minimum = min(image(:));
image = image - minimum;   %  2.6.10
% the image minimum is now zero
image = image/max(image(:));
image = double(image);
%rescaled_image = uint16(image);


