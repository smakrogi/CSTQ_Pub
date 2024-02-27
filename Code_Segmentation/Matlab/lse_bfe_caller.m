function [seg,level_set,iter_to_converge] = lse_bfe_caller(InputImage,mask,Params)
%    This code implements the two-phase formulation of the model in:
%      C. Li, R. Huang, Z. Ding, C. Gatenby, D. N. Metaxas, and J. C. Gore,
%      "A Level Set Method for Image Segmentation in the Presence of Intensity
%      Inhomogeneities with Application to MRI", IEEE Trans. Image Processing, 2011
%    The two-phase formulation uses the signs of a level set function to represent
%    two disjoint regions, and therefore can be used to segment an image into two regions,
%    which are represented by (u>0) and (u<0), where u is the level set function.
%
%    All rights researved by Chunming Li, who formulated the model, designed and
%    implemented the algorithm in the above paper.
%
% E-mail: lchunming@gmail.com
% URL: http://www.engr.uconn.edu/~cmli/
% Copyright (c) by Chunming Li
% Author: Chunming Li
% Edits: S. Makrogiannis <smakrogiannis@desu.edu>.

%-- Default settings
if(~isfield(Params,'LS_mu'))
    Params.LS_mu=1; % coefficient for distance regularization term (regularize the level set function)
end

A=255;
InputImage=A*normalize01(InputImage); % rescale the image intensities
nu=0.001*A^2; % coefficient of arc length term

sigma = 4; %8;4;2; % scale parameter that specifies the size of the neighborhood

iter_inner=int32(5);   % inner iteration for level set evolution

timestep=.1; %.1;

% figure(1);
% imagesc(InputImage,[0, 255]); colormap(gray); axis off; axis equal

% % initialize level set function
% c0=1;
% initialLSF = c0*ones(size(InputImage));
% initialLSF(70:140,150:230) = -c0;

%-- SDF
%   Get the distance map of the initial mask
% Initial level set
mask = mask(:,:,1);
initialLSF = bwdist(1-mask, 'euclidean')-bwdist(mask, 'euclidean')-mask+.5;
u=double(initialLSF);

% figure(1); subplottight(3,4,9); axis image; axis off; colorbar;
% hold on;
% contour(u,[0 0],'r');
% title('Initial contour');

% figure(2);
% imagesc(InputImage,[0, 255]); colormap(gray); axis off; axis equal
% hold on;
% contour(u,[0 0],'r');
% title('Initial contour');

epsilon=1;
b=ones(size(InputImage));  %%% initialize bias field

K=fspecial('gaussian',round(2*sigma)*2+1,sigma); % Gaussian kernel
% KI=conv2(InputImage,K,'same');
KONE=conv2(ones(size(InputImage)),K,'same');

[row,col]=size(InputImage);

for n=1:Params.LS_Iter
    u_n = u;

if ispc
 [u, b]= lse_bfe_mex(u_n,InputImage,b,K,KONE,nu,timestep,Params.LS_mu,epsilon,iter_inner);
else
 [u, b]= lse_bfe(u_n,InputImage,b,K,KONE,nu,timestep,Params.LS_mu,epsilon,iter_inner);
end

    if(mod(n,10) == 0) && Params.display
        showphi(InputImage,u,n);
    end
    
    indicator = checkstop(u_n,u,timestep);
    if indicator % decide to stop or continue
        seg = u >= 0; %-- Get mask from levelset
        level_set = u;
        iter_to_converge = n;
        return;
    end
end

% Mask =(InputImage>10);
% Img_corrected=normalize01(Mask.*InputImage./(b+(b==0)))*255;
% 
% figure(2); imagesc(b);  colormap(gray); axis off; axis equal; colorbar;
% title('Bias field');
% %
% figure(3);
% imagesc(Img_corrected); colormap(gray); axis off; axis equal; colorbar;
% title('Bias corrected image');

% Create mask from SDF.
seg = u >= 0; %-- Get mask from levelset
level_set = u;
iter_to_converge = n;

end