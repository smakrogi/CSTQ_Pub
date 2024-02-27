function SpatialHessianDetMatrix = SpatialHessianOnTempoDerivDetector(CurrentFrame, NextFrame, sigma_spatial, sigma_temporal)
% syntax: SpatialHessianDetMatrix = SpatialHessianOnTempoDerivDetector(CurrentFrame, NextFrame, sigma_spatial, sigma_temporal)
% S. Makrogiannis, MIVIC, PEMACS, DESU <smakrogiannis@desu.edu>

% Temporal derivative.
I_z = NextFrame - CurrentFrame;


% Spatial Hessian.
% First order spatial derivatives.
[I_xz, I_yz] = CalculateSpatioTemporalDerivatives(I_z, I_z);

[I_xxz, I_yxz] = ...
    CalculateSpatioTemporalDerivatives(I_xz, I_xz);

[I_xyz, I_yyz] = ...
    CalculateSpatioTemporalDerivatives(I_yz, I_yz);


% Determinant.
SpatialHessianDetMatrix = I_xxz .* I_yyz - I_xyz.^2;


% Scale normalization.
gamma_s = 1;
gamma_t = 0.5;

SpatialHessianDetMatrix = sigma_spatial^(2*gamma_s) * sigma_temporal^gamma_t * ...
    SpatialHessianDetMatrix;

% Calculate function of determinant.
SpatialHessianDetMatrix = SpatialHessianDetMatrix.^2;
SpatialHessianDetMatrix = SpatialHessianDetMatrix.^(1/6);

end