function BackgroundImage = EstimateBackgroundImage(Training_Data)
% Estimate background image from all frames.
% S. Makrogiannis, MIVIC, PEMACS, DESU <smakrogiannis@desu.edu>

% Using the median filter.
Training_Data_Matrix = cat(3,Training_Data{:});
Training_Data_Matrix = double(Training_Data_Matrix);
% figure, montage(Training_Data_Matrix,'DisplayRange',[0,255]); axis image; colorbar;

background_estimation_method = 'svd_low_rank';

switch background_estimation_method
    case 'median'
        BackgroundImage = median(Training_Data_Matrix,3);
    case 'gradient_tempo'
        % Use image gradient.
        [~,~,Gz] = imgradientxyz(Training_Data_Matrix);
        BackgroundImage = mean(Gz,3);
    case 'svd_low_rank'
        % Use SVD to approximate the background.
        Input_SVD = reshape(Training_Data_Matrix, [], size(Training_Data_Matrix, 3));
        [U, S, V] = svds(Input_SVD);
        Approximated_Data_Matrix = U*S*V';
        BackgroundImage = reshape(Approximated_Data_Matrix, size(Training_Data_Matrix, 1), ...
            size(Training_Data_Matrix, 2), []);
end
end