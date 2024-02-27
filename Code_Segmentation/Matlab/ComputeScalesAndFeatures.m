function [DiffusedCurrentFrame,FeatureMap,DiffusedPreviousFrame,DiffusedNextFrame,sigma_spatial,sigma_temporal] = ...
    ComputeScalesAndFeatures(CurrentFrame,PreviousFrame,NextFrame,Params)
% Spatio-temporal diffusion.
% DiffusedCurrentFrame is output of motion anisotropic diffusion.
% S. Makrogiannis, MIVIC, PEMACS, DESU <smakrogiannis@desu.edu>

% Initialize parameters.
external_diff_iter = round(Params.ST_Diff_Iter/Params.internal_diff_iter);
FeatureMap = zeros([size(CurrentFrame), external_diff_iter]);

if Params.ST_Diff_Type == 1
    scale_space_string = 'linear';
else
    scale_space_string = 'non-linear';
end
fprintf('Scale space: %s\n', scale_space_string);
fprintf('Feature detection: %s\n', Params.motion_activity_measure);


% Generate scales.
OriginalFrameMatrix = cat(3,PreviousFrame, CurrentFrame, NextFrame);
sigma_spatial = zeros(1, external_diff_iter);
sigma_temporal = zeros(1, external_diff_iter);
t_spatial = zeros(1, external_diff_iter);
t_temporal = zeros(1, external_diff_iter);
internal_diff_iter = zeros(1, external_diff_iter);

DiffusedCurrentFrame = zeros(size(CurrentFrame,1),size(CurrentFrame,2),external_diff_iter);
DiffusedPreviousFrame = zeros(size(CurrentFrame,1),size(CurrentFrame,2),external_diff_iter);
DiffusedNextFrame = zeros(size(CurrentFrame,1),size(CurrentFrame,2),external_diff_iter);


% Compute deltas, sigma and t for scale sampling.
% Define sampling functions.
linear_scale = @(sigma0, ii, delta_sigma) sigma0 + ii * delta_sigma;
exponential_scale = @(tau0, ii, delta_sigma) exp(tau0 + ii * delta_sigma);
inv_linear_scale = @(internal_diff_iter, sigma, tau0, delta_sigma) internal_diff_iter * ...
    (sigma - tau0) / delta_sigma;
inv_exponential_scale = @(internal_diff_iter, sigma, tau0, delta_sigma) internal_diff_iter * ...
    log(sigma/exp(tau0)) / delta_sigma;

% Set scale sampling variables.
delta_spatial_current_frame = 1/(4 *(Params.TS_Ratio+1));
% 1/(4 *(Params.TS_Ratio+1)), or 1/(8*(Params.TS_Ratio+1));
delta_temporal_current_frame = Params.TS_Ratio*delta_spatial_current_frame;
tau0 = 0;
delta_sigma_spatial = Params.internal_diff_iter * delta_spatial_current_frame;
delta_sigma_temporal = Params.internal_diff_iter * delta_temporal_current_frame;


% Scale generation loop.
for ii=1:external_diff_iter
    switch Params.scale_sampling
        case 'linear'
            sigma_spatial(ii) = linear_scale(tau0, ii, delta_sigma_spatial);
            sigma_temporal(ii) = linear_scale(tau0, ii, delta_sigma_temporal);
        case 'exponential'
            sigma_spatial(ii) = exponential_scale(tau0, ii, delta_sigma_spatial);
            sigma_temporal(ii) = exponential_scale(tau0, ii, delta_sigma_temporal);
    end
    
    % Generate scale.
    switch Params.ST_Diff_Type
        case 1 % anisotropic linear.
            DiffusedFrameMatrix = ...
                imgaussfilt3(OriginalFrameMatrix, ...
                [sigma_spatial(ii), sigma_spatial(ii), sigma_temporal(ii)]);
            
            %             FrameMatrix = cat(3,PreviousFrame, CurrentFrame, NextFrame);
            %             DiffusedFrameMatrix2 = ...
            %                 imgaussfilt3(FrameMatrix, ...
            %                 [delta_sigma_spatial, delta_sigma_spatial, delta_sigma_temporal]);
            %             Error = (DiffusedFrameMatrix(:,:,2)-DiffusedFrameMatrix2(:,:,2))./DiffusedFrameMatrix2(:,:,2);
            %             figure, imagesc(Error); axis image; colorbar
            
            DiffusedCurrentFrame(:,:,ii) = DiffusedFrameMatrix(:,:,2);
            DiffusedPreviousFrame(:,:,ii) = DiffusedFrameMatrix(:,:,1);
            DiffusedNextFrame(:,:,ii) = DiffusedFrameMatrix(:,:,3);
        case 2 % anisotropic non-linear.
            % Calculate the required internal diffusion iterations.
            switch Params.scale_sampling
                case 'linear'
                    internal_diff_iter(ii) = inv_linear_scale(Params.internal_diff_iter, ...
                        sigma_spatial(ii), tau0, delta_sigma_spatial);
                    sigma_spatial_prev = linear_scale(tau0, ii-1, delta_sigma_spatial);
                    internal_diff_iter_prev = inv_linear_scale(Params.internal_diff_iter, ...
                        sigma_spatial_prev, tau0, delta_sigma_spatial);
                    internal_diff_iter(ii) = round(internal_diff_iter(ii) - internal_diff_iter_prev);
                case 'exponential'
                    internal_diff_iter(ii) = inv_exponential_scale(Params.internal_diff_iter, ...
                        sigma_spatial(ii), tau0, delta_sigma_spatial);
                    if ii == 1 && tau0 == 0
                        sigma_spatial_prev = 0;
                    else
                        sigma_spatial_prev = exponential_scale(tau0, ii-1, delta_sigma_spatial);
                    end
                    internal_diff_iter_prev = inv_exponential_scale(Params.internal_diff_iter, ...
                        sigma_spatial_prev, tau0, delta_sigma_spatial);
                    internal_diff_iter(ii) = round(internal_diff_iter(ii) - internal_diff_iter_prev);
            end
            
            % Apply S-T diffusion.
            [DiffusedCurrentFrame(:,:,ii), DiffusedPreviousFrame(:,:,ii), DiffusedNextFrame(:,:,ii),...
                delta_spatial_current_frame,delta_temporal_current_frame] = ...
                MotionColorAnisotropicDiffusion(CurrentFrame, internal_diff_iter(ii), ...
                Params.Kappa, PreviousFrame, NextFrame, Params.ST_Diff_Type, ...
                Params.TS_Ratio, Params.Lambda_Tempo);
    end
    
    
    % Normalize scales.
    if Params.ST_Diff_Type == 1
        % Gaussian scale space.
        if Params.normalize_scales
            t_spatial(ii) = sigma_spatial(ii)^2/2;
            t_temporal(ii) = sigma_temporal(ii)^2/2;
        else
            t_spatial(ii) = 1;
            t_temporal(ii) = 1;
        end
    else
        % Nonlinear diffusion scale space.
        if Params.normalize_scales
            t_spatial(ii) = sigma_spatial(ii)^2/2;
            t_temporal(ii) = sigma_temporal(ii)^2/2;
        else
            t_spatial(ii) = 1;
            t_temporal(ii) = 1;
        end
        
    end
    
    
    % Compute feature map.
    switch Params.motion_activity_measure
        case 'regions_active_pixels'
            FeatureMap(ii) =  CalculateDFD(double(DiffusedCurrentFrame(:,:,ii)), double(CurrentFrame) );
            FeatureMap(ii) = 255 * FeatureMap;
        case 'regions_st_laplace'
            % Laplacian of diffusion.
            FeatureMap(:,:,ii) = ...
                SpatioTemporalLaplacianBlobDetector(DiffusedCurrentFrame(:,:,ii), CurrentFrame, ...
                t_spatial(ii), t_temporal(ii));
        case 'regions_st_moments'
            % Spatio-temporal using moments matrix (Harris, Shi/Tomasi-like).
            FeatureMap(:,:,ii) = ...
                SpatioTemporalMomentDetector(DiffusedCurrentFrame(:,:,ii), DiffusedNextFrame(:,:,ii), ...
                t_spatial(ii), t_temporal(ii));
        case 'regions_st_hessian'
            % Spatio-temporal Hessian-based analysis.
            FeatureMap(:,:,ii) = SpatioTemporalHessianDetector(DiffusedCurrentFrame(:,:,ii), DiffusedNextFrame(:,:,ii), ...
                t_spatial(ii), t_temporal(ii));
        case 'regions_sp_hessian_tempo_deriv'
            % Spatio-temporal Hessian-based analysis.
            FeatureMap(:,:,ii) = SpatialHessianOnTempoDerivDetector(DiffusedCurrentFrame(:,:,ii), DiffusedNextFrame(:,:,ii), ...
                t_spatial(ii), t_temporal(ii));
        otherwise
            FeatureMap(:,:,ii) = DiffusedCurrentFrame(:,:,ii);
    end
    
    
    % Prepare for next iteration.
    CurrentFrame = DiffusedCurrentFrame(:,:,ii);
    PreviousFrame = DiffusedPreviousFrame(:,:,ii);
    NextFrame = DiffusedNextFrame(:,:,ii);
end

fprintf('sigma_spatial: ');
fprintf(' %g ', sigma_spatial);
fprintf('\n');
fprintf('sigma_temporal: ');
fprintf(' %g ', sigma_temporal);
fprintf('\n');

end