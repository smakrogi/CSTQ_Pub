function status=showphi(I, phi, i)
% show curve evolution of phi

% Copyright (c) 2009,
% Yue Wu @ ECE Department, Tufts University
% All Rights Reserved

figure(1); subplottight(3,4,9);
I = double(I);
imagesc(I/max(I(:)),[0,1]); 
hold on;

%%contour(phi, [0 0], 'r','LineWidth',1);
contour(phi, [0 0], 'b','LineWidth',1);
%       phi_bound_coordinates = contour(phi, [0 0]);
%       plot(phi_bound_coordinates(1,:), phi_bound_coordinates(2,:),...
%           'b.','LineWidth',1)

axis image;axis off;
hold off;
alpha(0.5);
title([num2str(i) ' Iterations']);
drawnow;

status = 0;