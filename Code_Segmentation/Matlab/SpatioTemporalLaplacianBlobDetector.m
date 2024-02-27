function [DoDiff_Map,sigma_spatial,sigma_temporal] = ...
    SpatioTemporalLaplacianBlobDetector(DiffusedCurrentFrame, CurrentFrame, ...
    sigma_spatial, sigma_temporal)
% Integral of diffusion (LoG, DoG).
% S. Makrogiannis, MIVIC, PEMACS, DESU <smakrogiannis@desu.edu>

% Compute DoG STIP.
DoDiff_Map = DiffusedCurrentFrame - CurrentFrame;

% Scale normalization.
gamma_s = 1;
gamma_t = 0.5;

DoDiff_Map = sigma_spatial^gamma_s * sigma_temporal^gamma_t * ...
    DoDiff_Map;

%      nScales = size(DoDiff_Map, 3);
%     for ii=2:nScales
%         stdev_ratio = std(DoDiff_Map(:,:,ii-1),0,[1,2])./std(DoDiff_Map(:,:,ii),0,[1,2]);
%         DoDiff_Map(:,:,ii) = stdev_ratio * DoDiff_Map(:,:,ii);
%     end

end