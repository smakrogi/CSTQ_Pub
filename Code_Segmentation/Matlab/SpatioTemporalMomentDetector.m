function [MomentDeterminantMatrix, MomentCornerMatrix] = ...
    SpatioTemporalMomentDetector(CurrentFrame, NextFrame, sigma_spatial, sigma_temporal)
% syntax: MomentEigenMatrix = DetectMomentFeatures(CurrentFrame, NextFrame);
% S. Makrogiannis, MIVIC, PEMACS, DESU <smakrogiannis@desu.edu>

%% Spatio-temporal Harris or Shi/Tomasi-like using the moment matrix.
k = 0.04; % 0.04,0.06,0.001;

% Compute first order derivatives.
[I_x, I_y, I_z] = CalculateSpatioTemporalDerivatives(CurrentFrame, NextFrame);

% Scale normalization.
I_x = NormalizeDerivative(I_x, [1,0,0], sigma_spatial, sigma_temporal);
I_y = NormalizeDerivative(I_y, [0,1,0], sigma_spatial, sigma_temporal);
I_z = NormalizeDerivative(I_z, [0,0,1], sigma_spatial, sigma_temporal);

% Compute structure tensor
% Tensor output.
[m, n, ~] = size(CurrentFrame);
StructureMatrix = zeros(m, n, 3, 3);
StructureMatrix(:,:,1,1) = I_x .^ 2;
StructureMatrix(:,:,2,2) = I_y .^ 2;
StructureMatrix(:,:,3,3) = I_z .^ 2;
StructureMatrix(:,:,1,2) = I_x .* I_y;
StructureMatrix(:,:,2,1) = StructureMatrix(:,:,1,2);
StructureMatrix(:,:,1,3) = I_x .* I_z;
StructureMatrix(:,:,3,1) = StructureMatrix(:,:,1,3);
StructureMatrix(:,:,2,3) = I_y .* I_z;
StructureMatrix(:,:,3,2) = StructureMatrix(:,:,2,3);

% Sum of w times structure matrix for each point in neighborhood.
% Gaussian convolution/multiplication
structurematrixSize = size(StructureMatrix);
MomentMatrix = zeros(structurematrixSize);
for ii=1:structurematrixSize(3)
    for jj=1:structurematrixSize(4)
        MomentMatrix(:,:,ii,jj) = imgaussfilt(StructureMatrix(:,:,ii,jj));
    end
end

% Find three eigenvalues.
Shifted_MomentMatrix = shiftdim(MomentMatrix,2);
Reshaped_MomentMatrix = reshape(Shifted_MomentMatrix, ...
    [size(Shifted_MomentMatrix,1), ...
    size(Shifted_MomentMatrix,2), ...
    (size(Shifted_MomentMatrix,3)*size(Shifted_MomentMatrix,4))]);

MomentEigenValuesVector = zeros(3,size(Reshaped_MomentMatrix,3));
for ii=1:size(Reshaped_MomentMatrix,3), ...
        MomentEigenValuesVector(:,ii) = eig(Reshaped_MomentMatrix(:,:,ii));
end

% Detect features from eigenvalues (determinant, trace, or other rules).
MomentDeterminantVector = prod(MomentEigenValuesVector);
MomentCornerVector = MomentDeterminantVector - k * sum(MomentEigenValuesVector).^3;
MomentDeterminantMatrix = reshape(MomentDeterminantVector, size(CurrentFrame));
MomentCornerMatrix = reshape(MomentCornerVector, size(CurrentFrame));

MomentDeterminantMatrix = MomentDeterminantMatrix.^2;
MomentDeterminantMatrix = MomentDeterminantMatrix.^(1/6);
MomentCornerMatrix = MomentCornerMatrix.^2;
MomentCornerMatrix = MomentCornerMatrix.^(1/6);

end