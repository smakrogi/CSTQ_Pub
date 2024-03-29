function [WatershedMap,ParzenEdgeMap,GInputImage]=...
    WatershedSegmentation(InputImage,SelectedScaleMap,parzenbw,parzendim,threshold_ImHMin,watershed_input,watershed_minima,varargin)
% syntax: [WatershedMap,ParzenEdgeMap,GInputImage]=...
%   WatershedSegmentation(InputImage,SelectedScaleMap,parzenbw,parzendim,threshold_ImHMin,watershed_input,watershed_minima,varargin)
% S. Makrogiannis, MIVIC, PEMACS, DESU <smakrogiannis@desu.edu>


%#realonly
InputImage=double(InputImage);

% Compute edge map.
switch watershed_input
    case 'original'
        ParzenEdgeMap = InputImage;
    case 'edges'
        %if prefiltering is used
        if ~isempty(varargin)
            
            filtertype=varargin{1};
            gsigma=varargin{2};
            
            switch filtertype
                case 1%gaussian
                    G=Gfilt(size(InputImage,1),size(InputImage,2),varargin{2});     %A is the gauss dimension of the filter,B the s.d.
                    FG=fft2(G);
                    FInputImage=fft2(InputImage);
                    FGInputImage=FG.*FInputImage;
                    GInputImage=real(ifft2(FGInputImage));
                    GInputImage=fftshift(GInputImage);
                    
                case 2%nonlinear diffusion
                    lambda=0.25;
                    K=5;
                    iterations = round((gsigma*gsigma)/(2.0*lambda));
                    GInputImage=AnisotropicDiffusion(InputImage,iterations,K,lambda);
                    
                case 3%median
                    filterSize = varargin{2};
                    GInputImage = medfilt2(InputImage, [filterSize, filterSize]);
            end
            InputImage=GInputImage;
        end
        
        % Find edges using Parzen KDE.
        ParzenEdgeMap=ParzenEdgesFast(InputImage,parzendim,parzenbw);%
        ParzenEdgeMap=1-ParzenEdgeMap;
        ParzenEdgeMap=round(ParzenEdgeMap*255);
end


% Choose minima.
switch watershed_minima
    case 'edge_map_min'
        % Remove h-minima using reconstruction.
        Extendedminima = imextendedmin(ParzenEdgeMap,threshold_ImHMin);
        %5 for Sim4  %1  0.75  0.5 better separation for hela2
        
    case 'feat_map_max'
        Extendedminima = SelectedScaleMap;
        
    case 'edge_map_and_feat_map'
        Extendedminima = imextendedmin(ParzenEdgeMap,threshold_ImHMin) | SelectedScaleMap;
end


% Impose the extended minima onto the original edge map.
ParzenEdgeMapExtendedmin = imimposemin(ParzenEdgeMap, Extendedminima);


% Apply watershed.
WatershedMap=watershed(ParzenEdgeMapExtendedmin);
% may need to apply morphological operations after watershed
