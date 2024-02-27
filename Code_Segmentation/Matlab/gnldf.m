function Imf = gnldf(In,N,dt,diffunc)
%/************************************************************************\
%/*                       KYUNG HEE UNIVERSITY                           *\
%/*                       Biomedical Department                          *\
%/*                 Medical Imaging System Laboratory                    *\
%/*                                                                      *\
%/*Name of Program: Geometric Nonlinear Diffusion Filtering              *\
%/*By: Eric Michel Glez.                                                 *\
%/*Date: 16th February 2011                                              *\
%/************************************************************************\
%
% Arguments:
%       I           - Input image
%       N           - Number of iterations.
%       dt          - Constant integration, 0<dt<1/4 for a 2D problem with 
%                     4 point neighbors. (Max. value of 0.25 for numerical
%                     stability)
%       diffunc     - 'wregion' = Perona Malik diffusion equation 1
%                     'hgrad' = Perona Malik diffusion equation 2
%                     'sigmoid' = Sigmoid function
%
% Returns:
% Imf      - Filtered Image.
%
%
% Usage Example:
% Imf = gnldf(Imf,5,0.25,'wregion');
%
%  References:                                                            
%  [1]  Eric Michel, Min H. Cho and Soo Y. Lee, "Geometric nonlinear 
%       diffusion filter and its application to X-ray imaging"
%       BioMedical Engineering OnLine 2011, 10:47.
%       http://www.biomedical-engineering-online.com/content/10/1/47
% 
%       Any comments and suggestions to: eric.michel.glez@gmail.com
%                     
%                      Copyright (c) since 2011 ERIC MICHEL     
%
%                   KEEP TRYING... NOTHING IS IN VAIN!!!
%**************************************************************************
%**************************************************************************
if (nargin<1) 
   error('not enough arguments (At least 2 should be given)');
   fprintf(1,'Not enough arguments');
   return;
end
if ~exist('N')
   N=1;
end
if ~exist('dt')
   dt = 0.25;
end
if ~exist('diffunc')
   diffunc = 'wregion';
end
if ndims(In)~=2
  error('Sorry, DIFFILTERING only operates on 2D grey-scale images');
end;
%Setting initial conditions
I = In;
[height,weight] = size(I);
max_i = max(I(:));
I(~isfinite(I))=max_i; % Eliminate Infinite values
Imf = I;
%------------------------------------------
% Automatic Computation of parameter "d"
%------------------------------------------
    ImAux = padarray(Imf,[1 1],'symmetric','both');    
    %ImAux2 =medfilt2(ImAux);
    ImAux2 =medfilt2(abs(ImAux));
    dxd = (ImAux2(2:height+1,3:weight+2)-ImAux2(2:height+1,1:weight))/2;
    dyd = (ImAux2(3:height+2,2:weight+1)-ImAux2(1:height,2:weight+1))/2;
    GI_mag = single((dxd.*dxd+dyd.*dyd).^(1/2));
    % Using Median Absolute Deviation (MAD)
    d = 1.4826*median(abs(GI_mag(:)-median(GI_mag(:))))+eps;
    clear GI_mag;
    clear dxd; clear dyd;
%------------------------------------------
for ni=1:N
    
    if ni>N
        break;
    end;
    
    % Construct ImAux which is the same as Im but has an extra padding of zeros around it.
    ImAux2 = padarray(Imf,[1 1],'symmetric','both');
    
    Ax = (ImAux2(2:height+1,3:weight+2) + ImAux2(2:height+1,1:weight))/2;
    Ay = (ImAux2(3:height+2,2:weight+1) + ImAux2(1:height,2:weight+1))/2;
    dE = ImAux2(2:height+1,3:weight+2)   - Imf;       % difference East
    dW = ImAux2(2:height+1,1:weight)     - Imf;       % difference West 
    
    dN = ImAux2(1:height,2:weight+1)     - Imf;       % difference North
    dS = ImAux2(3:height+2,2:weight+1)   - Imf;       % difference South
    
    clear ImAux2;
    Dx = abs(dE-dW) - d;       %In order to smooth small edges, more SNR                        
    Dx(Dx<=0)=0;
    Dy = abs(dN-dS) - d;       %In order to smooth small edges, more SNR                        
    Dy(Dy<=0)=0;
    signo_x = (dE+dW)./(abs(dE+dW)+eps);
    signo_y = (dN+dS)./(abs(dN+dS)+eps);
    Gx = Imf + signo_x.*Dx/2;
    Gy = Imf + signo_y.*Dy/2;
    clear signo_x; clear signo_y;
    Px  = abs(Gx - Ax);
    Py  = abs(Gy - Ay);
    clear Ax; clear Gx;
    clear Ay; clear Gy;            
    %Diffusivity function        
    Cx = single(feval(diffunc,Dx,Px));
    Cy = single(feval(diffunc,Dy,Py));
    clear Dx; clear Dy; 
    clear Px; clear Py; 
    
    
    %Solved by Explicit scheme
    Imf = Imf + dt*((dE+dW).*Cx + (dN+dS).*Cy);
       
    
    clear Cx; clear Cy;
    clear dE; clear dW; clear dN; clear dS;
end
return;
%--------------------------------------------
% SOME DIFFUSIVITY FUNCTIONS                |
%--------------------------------------------
%-----------------------------------------
% Favours wide regions over smaller ones |
%-----------------------------------------
%Perona-Malik 1
function y = wregion(D,P)
    y = 1./(1+ (D./(abs(P) + eps)).^2);
return;
%-----------------------------------------------------
% Favours high contrast edges over low contrast ones |
%-----------------------------------------------------
%Perona-Malik 2
function y = hgrad(D,P)
    y = exp(-(D./(abs(P) + eps)).^4);
return;
%---------------------------------------
% Sigmoid diffusivity function     |
%---------------------------------------
%General Function
function y = sigmoid(D,P)
    y = 1./(1+exp(-(abs(P)-abs(D))*50));
return;
