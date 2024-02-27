function ST_Hess_Det_Matrix = SpatioTemporalHessianDetector(CurrentFrame, NextFrame, sigma_spatial, sigma_temporal)
% syntax: ST_Hess_Det_Matrix = DetectSpatioTemporalHessianFeatures(CurrentFrame, NextFrame, sigma_spatial, sigma_temporal)
% S. Makrogiannis, MIVIC, PEMACS, DESU <smakrogiannis@desu.edu>

%% Use Hessian

% First order spatio-temporal derivatives.
[I_x, I_y, I_z] = CalculateSpatioTemporalDerivatives(CurrentFrame, NextFrame);
% I_x = NormalizeDerivative(I_x, [1,0,0], sigma_spatial, sigma_temporal);
% I_y = NormalizeDerivative(I_y, [0,1,0], sigma_spatial, sigma_temporal);
% I_z = NormalizeDerivative(I_z, [0,0,1], sigma_spatial, sigma_temporal);

% Hessian_Spatio_Temporal: [I_xx, I_xy, I_xz; I_yx, I_yy, I_yz; I_zx, I_zy, I_zz];
Hessian_Spatio_Temporal = zeros([size(CurrentFrame), 3, 3]);
[Hessian_Spatio_Temporal(:,:,1,1), Hessian_Spatio_Temporal(:,:,1,2), ...
    Hessian_Spatio_Temporal(:,:,1,3)] = ...
    CalculateSpatioTemporalDerivatives(I_x, I_z);
% Hessian_Spatio_Temporal(:,:,1,1) = NormalizeDerivative(Hessian_Spatio_Temporal(:,:,1,1), ...
%     [1,0,0], sigma_spatial, sigma_temporal);
% Hessian_Spatio_Temporal(:,:,1,2) = NormalizeDerivative(Hessian_Spatio_Temporal(:,:,1,2), ...
%     [0,1,0], sigma_spatial, sigma_temporal);
% Hessian_Spatio_Temporal(:,:,1,3) = NormalizeDerivative(Hessian_Spatio_Temporal(:,:,1,3), ...
%     [0,0,1], sigma_spatial, sigma_temporal);

[Hessian_Spatio_Temporal(:,:,2,1), Hessian_Spatio_Temporal(:,:,2,2), ...
    Hessian_Spatio_Temporal(:,:,2,3)] = ...
    CalculateSpatioTemporalDerivatives(I_y, I_z);
% Hessian_Spatio_Temporal(:,:,2,1) = NormalizeDerivative(Hessian_Spatio_Temporal(:,:,2,1), ...
%     [1,0,0], sigma_spatial, sigma_temporal);
% Hessian_Spatio_Temporal(:,:,2,2) = NormalizeDerivative(Hessian_Spatio_Temporal(:,:,2,2), ...
%     [0,1,0], sigma_spatial, sigma_temporal);
% Hessian_Spatio_Temporal(:,:,2,3) = NormalizeDerivative(Hessian_Spatio_Temporal(:,:,2,3), ...
%     [0,0,1], sigma_spatial, sigma_temporal);

[Hessian_Spatio_Temporal(:,:,3,1), Hessian_Spatio_Temporal(:,:,3,2), ...
    Hessian_Spatio_Temporal(:,:,3,3)] = ...
    CalculateSpatioTemporalDerivatives(I_z, I_z);
% Hessian_Spatio_Temporal(:,:,3,1) = NormalizeDerivative(Hessian_Spatio_Temporal(:,:,3,1), ...
%     [1,0,0], sigma_spatial, sigma_temporal);
% Hessian_Spatio_Temporal(:,:,3,2) = NormalizeDerivative(Hessian_Spatio_Temporal(:,:,3,2), ...
%     [0,1,0], sigma_spatial, sigma_temporal);
% Hessian_Spatio_Temporal(:,:,3,3) = NormalizeDerivative(Hessian_Spatio_Temporal(:,:,3,3), ...
%     [0,0,1], sigma_spatial, sigma_temporal);

% Calculate determinant.
Shifted_Hessian_Spatio_Temporal = shiftdim(Hessian_Spatio_Temporal,2);
Reshaped_Hessian_Spatio_Temporal = reshape(Shifted_Hessian_Spatio_Temporal, ...
    [size(Shifted_Hessian_Spatio_Temporal,1), ...
    size(Shifted_Hessian_Spatio_Temporal,2), ...
    (size(Shifted_Hessian_Spatio_Temporal,3)*size(Shifted_Hessian_Spatio_Temporal,4))]);

ST_Hess_Det_Vector = zeros(1,size(Reshaped_Hessian_Spatio_Temporal,3));
for ii=1:size(Reshaped_Hessian_Spatio_Temporal,3), ...
        ST_Hess_Det_Vector(ii) = det(Reshaped_Hessian_Spatio_Temporal(:,:,ii));
end
ST_Hess_Det_Matrix = reshape(ST_Hess_Det_Vector, size(CurrentFrame));

% Check the eigenvalues.
% ST_Hess_Det_Vector = zeros(size(Reshaped_Hessian_Spatio_Temporal,3),3);
% tic, for ii=1:size(Reshaped_Hessian_Spatio_Temporal,3), ...
%         ST_Hess_Det_Vector(ii,:) = eig(Reshaped_Hessian_Spatio_Temporal(:,:,ii)); end, toc
% %         if abs(sum(sign(eigenValues)))==3
% %             ST_Hess_Det_Matrix(ii,jj) = prod(eigenValues);
% %             ST_Hess_Det_Matrix(ii,jj) = det(LocalMatrix);
% %         end


% Scale normalization.
gamma_s = 1;
gamma_t = 1;

ST_Hess_Det_Matrix = sigma_spatial^(2*gamma_s) * sigma_temporal^gamma_t * ...
    ST_Hess_Det_Matrix;


% Calculate function of determinant.
ST_Hess_Det_Matrix = ST_Hess_Det_Matrix.^2;
ST_Hess_Det_Matrix = ST_Hess_Det_Matrix.^(1/6);

end