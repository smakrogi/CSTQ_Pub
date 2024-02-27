function [I_x, I_y, I_z] = CalculateSpatioTemporalDerivatives(CurrentFrame, NextFrame)
% S. Makrogiannis, MIVIC, PEMACS, DESU <smakrogiannis@desu.edu>

[m, n, ~]=size(CurrentFrame);

rowC = [1:m];
rowN = [1 1:m-1];
% rowS = [2:m m];
colC = [1:n];
colE = [2:n n];
% colW = [1 1:n-1];

% Forward differences or central differences.
I_x = CurrentFrame(rowN,colC,:) - CurrentFrame(rowC,colC,:);
I_y = CurrentFrame(rowC,colE,:) - CurrentFrame(rowC,colC,:);
I_z = NextFrame - CurrentFrame;

end