function [Mahal_Dist_Matrix, Sigma] = MahalanobisDistance(Data_Points, Eval_Points, centroid)
% syntax: [Mahal_Dist_Matrix, Sigma] = MahalanobisDistance(Data_Points,
% Eval_Points, centroid);
% Authors:
% S. Makrogiannis, MIVIC, PEMACS, DESU <smakrogiannis@desu.edu>

Sigma = cov(Data_Points);

Diff_Matrix = Eval_Points - centroid;
% [sig,mu,mah,outliers,s] = robustcov(x)

ISigma = pinv(Sigma);
Mahal_Dist_Matrix = sum((Diff_Matrix*ISigma) .* Diff_Matrix/2,2);
Mahal_Dist_Matrix = Mahal_Dist_Matrix.^0.5;


end