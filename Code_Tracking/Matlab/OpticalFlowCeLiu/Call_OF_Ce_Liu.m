function flow = Call_OF_Ce_Liu(Frame1, Frame2)

% addpath('mex');

% we provide two sequences "car" and "table"
% example = 'table';
example = 'example';

% load the two frames
% Frame1 = im2double(imread([example '1.jpg']));
% im2 = im2double(imread([example '2.jpg']));
original_size = size(Frame1);
Frame1 = Scale_Intensities_0_1(Frame1);
Frame2 = Scale_Intensities_0_1(Frame2);

Frame1 = imresize(Frame1,0.5,'bicubic');
Frame2 = imresize(Frame2,0.5,'bicubic');

% set optical flow parameters (see Coarse2FineTwoFrames.m for the definition of the parameters)
alpha = 0.012;
ratio = 0.75;
minWidth = 20;
nOuterFPIterations = 7;
nInnerFPIterations = 1;
nSORIterations = 30;

para = [alpha,ratio,minWidth,nOuterFPIterations,nInnerFPIterations,nSORIterations];

% this is the core part of calling the mexed dll file for computing optical flow
% it also returns the time that is needed for two-frame estimation
tic;
[vx,vy,warpI2] = Coarse2FineTwoFrames(Frame1,Frame2,para);
toc

% figure;imshow(Frame1);figure;imshow(warpI2);

vx = imresize(vx, original_size, 'bicubic');
vy = imresize(vy, original_size, 'bicubic');

% output gif
% clear volume;
% volume(:,:,:,1) = Frame1;
% volume(:,:,:,2) = Frame2;
% if exist('output','dir')~=7
%     mkdir('output');
% end
% frame2gif(volume,fullfile('output',[example '_input.gif']));
% volume(:,:,:,2) = warpI2;
% frame2gif(volume,fullfile('output',[example '_warp.gif']));


% visualize flow field
clear flow;
flow(:,:,1) = vx;
flow(:,:,2) = vy;
%imflow = flowToColor(flow);
% figure;imshow(imflow);
% imwrite(imflow,fullfile('output',[example '_flow.jpg']),'quality',100);
