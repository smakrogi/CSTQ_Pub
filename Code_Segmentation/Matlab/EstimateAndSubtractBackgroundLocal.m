function [PreviousFrameOut,CurrentFrameOut,NextFrameOut,MedianFrame] = ...
    EstimateAndSubtractBackgroundLocal(PreviousFrame,CurrentFrame,NextFrame)
% S. Makrogiannis, MIVIC, PEMACS, DESU <smakrogiannis@desu.edu>

% Subtract the background using the median.
Volume = cat(3,PreviousFrame,CurrentFrame,NextFrame);

% Subtract the median/mean.
MedianFrame = median(Volume,3);
median_value = median(MedianFrame(:));
% Volume = (Volume - median_value);
% Volume = (Volume - mean(double(Volume(:))));

% % Divide by the median/mean.
Volume = (double(Volume) / double(median_value));

% Subtract the background using z-scores.

% Subtract the background using Otsu's thresholding.
% [counts,edges] = histcounts(CurrentFrame, 1024);
% feature_threshold = otsuthresh(counts) * edges(end);
% figure(2), imagesc(MedianFrame>feature_threshold); axis image; colorbar

% Return the processed frames.
PreviousFrameOut = Volume(:,:,1);
CurrentFrameOut = Volume(:,:,2);
NextFrameOut = Volume(:,:,3);

end