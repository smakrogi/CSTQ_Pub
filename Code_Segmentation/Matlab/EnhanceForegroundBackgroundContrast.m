function [PreviousFrameOut,CurrentFrameOut,NextFrameOut] = ...
    EnhanceForegroundBackgroundContrast(PreviousFrame,CurrentFrame,NextFrame,Params)
% syntax: [PreviousFrameOut,CurrentFrameOut,NextFrameOut] = ...
%     EnhanceForegroundBackgroundContrast(PreviousFrame,CurrentFrame,NextFrame,Params);
% S. Makrogiannis, MIVIC, PEMACS, DESU <smakrogiannis@desu.edu>

% Scale intensities to [0,255].
PreviousFrame = double(PreviousFrame);
CurrentFrame = double(CurrentFrame);
NextFrame = double(NextFrame);

[PreviousFrame,CurrentFrame,NextFrame]  = ...
    ScaleImageIntensities(PreviousFrame,CurrentFrame,NextFrame);

% % Apply gamma transform.
% gamma = 1.5;
% c = 255/255.^gamma;
% PreviousFrame = c * PreviousFrame.^gamma;
% CurrentFrame = c * CurrentFrame.^gamma;
% NextFrame = c * NextFrame.^gamma;


% Apply CLAHE to three frames.
PreviousFrame = adapthisteq(uint8(PreviousFrame),...
    'NumTiles', [Params.CLAHE_tile_num Params.CLAHE_tile_num], 'ClipLimit', Params.CLAHE_clip_lim);
CurrentFrame = adapthisteq(uint8(CurrentFrame),...
    'NumTiles', [Params.CLAHE_tile_num Params.CLAHE_tile_num], 'ClipLimit', Params.CLAHE_clip_lim);
NextFrame = adapthisteq(uint8(NextFrame),...
    'NumTiles', [Params.CLAHE_tile_num Params.CLAHE_tile_num], 'ClipLimit', Params.CLAHE_clip_lim);

% Suppress background.
[PreviousFrame,CurrentFrame,NextFrame] = ...
    EstimateAndSubtractBackgroundLocal(PreviousFrame,CurrentFrame,NextFrame);

[PreviousFrameOut,CurrentFrameOut,NextFrameOut]  = ...
    ScaleImageIntensities(PreviousFrame,CurrentFrame,NextFrame);

% % Flatten intensities.
% se_size = 10;
% PreviousFrameOut = morphological_flattening(uint8(PreviousFrameOut), se_size);
% CurrentFrameOut = morphological_flattening(uint8(CurrentFrameOut), se_size);
% NextFrameOut = morphological_flattening(uint8(NextFrameOut), se_size);

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [PreviousFrameOut,CurrentFrameOut,NextFrameOut]  = ...
    ScaleImageIntensities(PreviousFrame,CurrentFrame,NextFrame)

Volume = cat(3,PreviousFrame,CurrentFrame,NextFrame);

int_min = min(Volume(:));
int_max = max(Volume(:));

Volume = (Volume-int_min)/(int_max-int_min);

Volume = 255 * Volume;

PreviousFrameOut = Volume(:,:,1);
CurrentFrameOut = Volume(:,:,2);
NextFrameOut = Volume(:,:,3);
end