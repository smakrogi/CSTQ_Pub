function Likelihood = NonParametricLikelihoodEstimation(Data_Points, Eval_Points, varargin)
% syntax: Normalized_Likelihood =
% NonParametricLikelihoodEstimation(Data_Points, Eval_Points, Centroid);
% Authors:
% S. Makrogiannis, MIVIC, PEMACS, DESU <smakrogiannis@desu.edu>

if isempty(varargin)
    bandwidth = 1;
else
    bandwidth = varargin{1};
end

[n, d] = size(Data_Points);
Likelihood = zeros(1,size(Eval_Points,1));

for ii=1:size(Eval_Points,1)
%     num_data_points = sum(cluster_labels==ii);
%     Cluster_Data_Points = Data_Points(cluster_labels==ii,:);
    sqDist = bsxfun(@minus,Eval_Points(ii,:),Data_Points).^2;
    sqDist = sum(sqDist, 2);
    kfun = exp(-sqDist/(2*bandwidth^2));
    Likelihood(ii) = (1/(n*bandwidth^d)) * (2*pi)^(-0.5*d) * sum(kfun, 1);
end

% Normalize.
% Likelihood = Likelihood/sum(Likelihood);

end