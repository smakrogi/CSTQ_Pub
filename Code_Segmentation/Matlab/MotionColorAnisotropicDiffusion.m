function [OutImage,OutPreviousFrame,OutNextFrame,delta_spatial_current_frame,delta_temporal_current_frame] = ...
    MotionColorAnisotropicDiffusion(InImage,iterations,K,...
    PreviousFrame,NextFrame,mode,tempotospaceratio,lambdatemporalframe)%#codegen
% syntax: [OutImage, OutPreviousFrame, OutNextFrame] = MotionColorAnisotropicDiffusion(InImage,iterations,K,...
%     PreviousFrame,NextFrame,mode,tempotospaceratio,lambdatemporalframe)
% OutImage is the diffused frame
%mode 1:linear, mode 2:nonlinear
% Works for one, or three channel images.
% S. Makrogiannis, MIVIC, PEMACS, DESU <smakrogiannis@desu.edu>

% Create three components
nChannels = size(InImage,3);
regularization_sigma = 0.5; % 0.25,0.5,0.75;

% if mode==2
    % Catte regularization.
%     [InImage, PreviousFrame, NextFrame] = ...
%         CatteRegularization(InImage, PreviousFrame, NextFrame, regularization_sigma);
% end


% Convert to double precision variables.
InImage=double(InImage);
PreviousFrame=double(PreviousFrame);
NextFrame=double(NextFrame);
OutImage=InImage;
OutPreviousFrame = PreviousFrame;
OutNextFrame = NextFrame;

[m,n,z]=size(InImage);

% Allocate variables for code generation.
fluxNPreviousFrame = zeros(size(InImage));
fluxEPreviousFrame = zeros(size(InImage));
fluxNNextFrame = zeros(size(InImage));
fluxENextFrame = zeros(size(InImage));
fluxTprevious = zeros(size(InImage));
fluxTnext = zeros(size(InImage));

%TimeDiffusionPixels=zeros(m,n,z);
rowC = [1:m];
rowN = [1 1:m-1];
rowS = [2:m m];
colC = [1:n];
colE = [2:n n];
colW = [1 1:n-1];

fluxN=zeros(m,n,z);
fluxE=zeros(m,n,z);

delta_spatial_current_frame = 1/(4 *(tempotospaceratio+1)); % 1/(4 *(tempotospaceratio+1)), or 1/(8*(tempotospaceratio+1));
delta_temporal_current_frame = tempotospaceratio*delta_spatial_current_frame;

fprintf('S-T diffusion %4c', ' ');
for ii=(1:iterations)
    
    progress = ( 100*(ii/iterations) );
    fprintf('\b\b\b\b%3.0f%%',progress);
    
    Deltas.deltaN=OutImage(rowN,colC,:)-OutImage(rowC,colC,:);
    Deltas.deltaE=OutImage(rowC,colE,:)-OutImage(rowC,colC,:);
    
    Deltas.deltaNPreviousFrame=OutPreviousFrame(rowN,colC,:)-OutPreviousFrame(rowC,colC,:);
    Deltas.deltaEPreviousFrame=OutPreviousFrame(rowC,colE,:)-OutPreviousFrame(rowC,colC,:);
    
    Deltas.deltaNNextFrame=OutNextFrame(rowN,colC,:)-OutNextFrame(rowC,colC,:);
    Deltas.deltaENextFrame=OutNextFrame(rowC,colE,:)-OutNextFrame(rowC,colC,:);
    
    Deltas.deltaTprevious=OutPreviousFrame-OutImage;
    Deltas.deltaTnext=OutNextFrame-OutImage;
    
    switch(mode)
        case 1
            fluxN=Deltas.deltaN;
            fluxE=Deltas.deltaE;
            
            fluxNPreviousFrame=Deltas.deltaNPreviousFrame;
            fluxEPreviousFrame=Deltas.deltaEPreviousFrame;
            
            fluxNNextFrame=Deltas.deltaNNextFrame;
            fluxENextFrame=Deltas.deltaENextFrame;
            
            fluxTprevious=Deltas.deltaTprevious;
            fluxTnext=Deltas.deltaTnext;
        case 2
            % Catte, Lions, Morel regularization.
            DeltaOutput = CatteRegularization(Deltas, nChannels, regularization_sigma);
            
            % Compute flux.
            for jj=1:nChannels
                fluxN(:,:,jj)=Deltas.deltaN(:,:,jj).*exp(-(1/K^2)*DeltaOutput.deltaN3d.^2);
                
                fluxE(:,:,jj)=Deltas.deltaE(:,:,jj).*exp(-(1/K^2)*DeltaOutput.deltaE3d.^2);
                
                fluxNPreviousFrame(:,:,jj)=Deltas.deltaNPreviousFrame(:,:,jj).*...
                    exp(-(1/K^2)*DeltaOutput.deltaN3dPreviousFrame.^2);
                
                fluxEPreviousFrame(:,:,jj)=Deltas.deltaEPreviousFrame(:,:,jj).*...
                    exp(-(1/K^2)*DeltaOutput.deltaE3dPreviousFrame.^2);
                
                fluxNNextFrame(:,:,jj)=Deltas.deltaNNextFrame(:,:,jj).*...
                    exp(-(1/K^2)*DeltaOutput.deltaN3dNextFrame.^2);
                
                fluxENextFrame(:,:,jj)=Deltas.deltaENextFrame(:,:,jj).* ...
                    exp(-(1/K^2)*DeltaOutput.deltaE3dNextFrame.^2);
                
                fluxTprevious(:,:,jj)=Deltas.deltaTprevious(:,:,jj).*...
                    exp(-(1/K^2)*DeltaOutput.deltaTprevious3d.^2);
                
                fluxTnext(:,:,jj)=Deltas.deltaTnext(:,:,jj).*...
                    exp(-(1/K^2)*DeltaOutput.deltaTnext3d.^2);
            end
    end
    
    OutImage=OutImage + delta_spatial_current_frame*(fluxN-fluxN(rowS,colC,:)+...
        fluxE-fluxE(rowC,colW,:))+...
        2*delta_temporal_current_frame*(fluxTprevious+fluxTnext);
    
    OutPreviousFrame = OutPreviousFrame + lambdatemporalframe*(fluxNPreviousFrame-fluxNPreviousFrame(rowS,colC,:)+...
        fluxEPreviousFrame-fluxEPreviousFrame(rowC,colW,:))-...
        4*lambdatemporalframe* fluxTprevious;
    
    OutNextFrame = OutNextFrame + lambdatemporalframe*(fluxNNextFrame-fluxNNextFrame(rowS,colC,:)+...
        fluxENextFrame-fluxENextFrame(rowC,colW,:))-...
        4*lambdatemporalframe*fluxTnext ;
end

fprintf('\n');

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function DeltaOutput = CatteRegularization(DeltaInput, nChannels, regularization_sigma)

% Catte regularization.

for ii=1:nChannels
    % Catte regularization (may need to change for multi-channel images).
    DeltaInput.deltaN(:,:,ii)=imgaussfilt(DeltaInput.deltaN(:,:,ii), regularization_sigma);
    DeltaInput.deltaE(:,:,ii)=imgaussfilt(DeltaInput.deltaE(:,:,ii), regularization_sigma);
    DeltaInput.deltaNPreviousFrame(:,:,ii)=imgaussfilt(DeltaInput.deltaNPreviousFrame(:,:,ii), regularization_sigma);
    DeltaInput.deltaEPreviousFrame(:,:,ii)=imgaussfilt(DeltaInput.deltaEPreviousFrame(:,:,ii), regularization_sigma);
    DeltaInput.deltaNNextFrame(:,:,ii)=imgaussfilt(DeltaInput.deltaNNextFrame(:,:,ii), regularization_sigma);
    DeltaInput.deltaENextFrame(:,:,ii)=imgaussfilt(DeltaInput.deltaENextFrame(:,:,ii), regularization_sigma);
    DeltaInput.deltaTprevious(:,:,ii)=imgaussfilt(DeltaInput.deltaTprevious(:,:,ii), regularization_sigma);
    DeltaInput.deltaTnext(:,:,ii)=imgaussfilt(DeltaInput.deltaTnext(:,:,ii), regularization_sigma);
end


% Compute l2 norm.
DeltaOutput.deltaN3d=sqrt(sum(DeltaInput.deltaN.^2,3));
DeltaOutput.deltaE3d=sqrt(sum(DeltaInput.deltaE.^2,3));

DeltaOutput.deltaN3dPreviousFrame=sqrt(sum(DeltaInput.deltaNPreviousFrame.^2,3));
DeltaOutput.deltaE3dPreviousFrame=sqrt(sum(DeltaInput.deltaEPreviousFrame.^2,3));

DeltaOutput.deltaN3dNextFrame=sqrt(sum(DeltaInput.deltaNNextFrame.^2,3));
DeltaOutput.deltaE3dNextFrame=sqrt(sum(DeltaInput.deltaENextFrame.^2,3));

DeltaOutput.deltaTprevious3d=sqrt(sum(DeltaInput.deltaTprevious.^2,3));
DeltaOutput.deltaTnext3d=sqrt(sum(DeltaInput.deltaTnext.^2,3));

end