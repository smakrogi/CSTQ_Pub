function [Likelihood, centroid, centroid_prob] = ParametricLikelihoodEstimation(Data_Points, Eval_Points, varargin)
% syntax: [Likelihood, centroid, centroid_prob] = ...
% ParametricLikelihoodEstimation(Data_Points, Eval_Points, varargin)
% Authors:
% S. Makrogiannis, MIVIC, PEMACS, DESU <smakrogiannis@desu.edu>

if isempty(varargin)
    centroid = mean(Data_Points);
else
    centroid = varargin{1};
end

d = size(Data_Points,2);

[Mahal_Dist_Matrix, Sigma] = MahalanobisDistance(Data_Points, Eval_Points, centroid);
SQ_Mahal_Dist_Matrix = Mahal_Dist_Matrix.^2;

Likelihood = ((2*pi)^d*det(Sigma))^(-0.5) * exp(-0.5*SQ_Mahal_Dist_Matrix);

centroid_prob = ((2*pi)^d*det(Sigma))^(-0.5);

%Likelihood = Likelihood / sum(Likelihood);
% centroid_prob = centroid_prob / sum(Likelihood);

end
