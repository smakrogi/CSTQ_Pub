function msd = Compute_MSD(Positions,n)

%Positions=Nb_Frames,Centroids_x,Centroids_y
% Check msd analyser in matlab
%Positions array nbframe,centroidx,centroidy
Nb_Frames = size(Positions,1); 
numberOfdeltaT = floor(Nb_Frames/n); %# for MSD, dt should be up to 1/4 of number of Positions points
msd = zeros(numberOfDeltaT,3); %# We'll store [mean_dr, std, n]
% msd for all deltaT's
for dt = 1:numberOfDeltaT
   delta_xy = Positions(1+dt:end,2:3) - Positions(1:end-dt,2:3);
%delta_y = Positions(1+dt:end,3) - Positions(1:end-dt,3);
 squaredDisplacement = sum(delta_x.^2,2); %# dx^2+dy^2
   msd(dt,1) = mean(squaredDisplacement); % average
   msd(dt,2) = std(squaredDisplacement); %std
   msd(dt,3) = length(squaredDisplacement); % n
end
plot(msd(:,1));
end