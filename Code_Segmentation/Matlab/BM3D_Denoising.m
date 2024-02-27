function OutputImage = BM3D_Denoising(InputImage,PSD)

% For other settings, use BM3DProfile.
% profile = BM3DProfile(); % equivalent to profile = BM3DProfile('np');
% y_est = BM3D(z, PSD, profile);

% Scale pixel intensities in [0,1].
max_val = max(InputImage(:));
InputImage = InputImage / max_val;

% Call BM3D With the default settings.
InputImage = BM3D(InputImage, PSD);

% Scale pixel intensities in [0,255].
OutputImage = InputImage * max_val;

end
