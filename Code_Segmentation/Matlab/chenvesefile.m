function [seg,level_set,iter_to_converge] = ...
    chenvesefile(I,mask,method,Params)
%==========================================================================

target_image_side_length = 256; % 200
%-- Default settings
%   length term Params.LS_mu = 0.2 and default method = 'chan'
if(~isfield(Params,'LS_mu'))
    Params.LS_mu=0.2; %      Params.LS_mu=0.5;
end

if(~exist('method','var'))
    method = 'chan';
end

%-- End default settings

%%
%-- Initializations on input image I and mask
%  resize original image
s = target_image_side_length/min(size(I,1),size(I,2)); % resize scale
%    s = 0.25;
if s<1
    I = imresize(I,s);
end

%   auto mask settings
if ischar(mask)
    switch lower (mask)
        case 'small'
            mask = maskcircle2(I,'small');
        case 'medium'
            mask = maskcircle2(I,'medium');
        case 'large'
            mask = maskcircle2(I,'large');
        case 'whole'
            mask = maskcircle2(I,'whole');
            %mask = init_mask(I,30);
        case 'whole+small'
            m1 = maskcircle2(I,'whole');
            m2 = maskcircle2(I,'small');
            mask = zeros(size(I,1),size(I,2),2);
            mask(:,:,1) = m1(:,:,1);
            mask(:,:,2) = m2(:,:,2);
        otherwise
            error('unrecognized mask shape name (MASK).');
    end
else
    % The mask is given as input parameter
    if (s<1)  %&& (~iter1 )
        mask = imresize(mask,s,'nearest');
    end
    if size(mask,1)>size(I,1) || size(mask,2)>size(I,2)
        error('dimensions of mask unmatch those of the image.')
    end
    switch lower(method)
        case 'multiphase'
            if  (size(mask,3) == 1)
                error('multiphase requires two masks but only gets one.')
            end
    end
    
end


switch lower(method)
    case 'chan'
        if size(I,3)== 3   % in this case we check class in case uint16
            P = rgb2gray(uint16(I));
            P = double(P);
        elseif size(I,3) == 2
            P = 0.5.*(double(I(:,:,1))+double(I(:,:,2)));
        else
            P = double(I);     % We store the original image
        end
        layer = 1;
        
    case 'vector'
        s = target_image_side_length./min(size(I,1),size(I,2)); % resize scale
        I = imresize(I,s);
        mask = imresize(mask,s);
        layer = size(I,3);
        if layer == 1
            disp('only one image component for vector image')
        end
        P = double(I);
        
    case 'multiphase'
        layer = size(I,3);
        if size(I,1)*size(I,2)>200^2
            s = 200./min(size(I,1),size(I,2)); % resize scale
            I = imresize(I,s);
            mask = imresize(mask,s);
        end
        
        P = double(I);  %P store the original image
    otherwise
        error('!invalid method')
end
%-- End Initializations on input image I and mask

%%
%--   Core function
switch lower(method)
    case {'chan','vector'}
        %-- SDF
        %   Get the distance map of the initial mask
        % Initial level set
        mask = mask(:,:,1);
        phi0 = bwdist(1-mask, 'euclidean')-bwdist(mask, 'euclidean')-mask+.5;
        %   initial force, set to eps to avoid division by zeros
        force = eps;
        %-- End Initialization
       
        %-- Main loop
        for n=1:Params.LS_Iter
            inidx = find(phi0>=0); % frontground index   % inside level set distance
            outidx = find(phi0<0); % background index    % outside values by levet set distance
            force_image = 0; % initial image force for each layer
            for i=1:layer      % layer = 1 gray or more if colored
                L = im2double(P(:,:,i)); % get one image component one color channel
                c1 = sum(sum(L.*HeavisideCV(phi0)))/(length(inidx)+eps); % average inside of Phi0
                c2 = sum(sum(L.*(1-HeavisideCV(phi0))))/(length(outidx)+eps); % verage outside of Phi0
                force_image=-(L-c1).^2+(L-c2).^2+force_image;
                % sum Image Force on all components (used for vector image)
                % if 'chan' is applied, this loop become one sigle code as a
                % result of layer = 1
            end
            
            % calculate the external force of the image
            force = Params.LS_mu*kappa(phi0)./max(max(abs(kappa(phi0))))+1/layer.*force_image;
            
            % normalized the force
            force = force./(max(max(abs(force))));
            
            % get stepsize dt
            dt=0.5;      %  delta t
            
            % get parameters for checking whether to stop
            old = phi0;
            phi0 = phi0+dt.*force;
            new = phi0;
            indicator = checkstop(old,new,dt);
            
            % intermediate output
            if(mod(n,10) == 0) && Params.display
                showphi(I,phi0,n);
            end
            if indicator % decide to stop or continue
                iter_to_converge=n;
                %make mask from SDF
                seg = phi0>=0; %-- Get mask from levelset image binaire
                
%                 filename = strcat( name, 'levelset.png' );
%                 imwrite( phi0, filename );
               
                level_set = phi0;
                return;
            end
        end
        
        %make mask from SDF
        seg = phi0 >= 0; %-- Get mask from levelset
        level_set = phi0;
        iter_to_converge = n;
    case 'multiphase'
        %-- Initializations
        %   Get the distance map of the initial masks
        mask1 = mask(:,:,1);
        mask2 = mask(:,:,2);
        % %         phi1=bwdist(mask1)-bwdist(1-mask1)+im2double(mask1)-.5;%Get phi1 from the initial mask 1
        % %  07/27/14       phi2=bwdist(mask2)-bwdist(1-mask2)+im2double(mask2)-.5;%Get phi1 from the initial mask 2
        phi1=bwdist(mask1,'euclidean')-bwdist(1-mask1,'euclidean')+mask1-.5;%Get phi1 from the initial mask 1
        phi2=bwdist(mask2,'euclidean')-bwdist(1-mask2,'euclidean')+mask2-.5;%Get phi1 from the initial mask 2
        
        %Main loop
        for n=1:Params.LS_Iter
            %-- Narrow band for each phase
            nb1 = find(phi1<1.2 & phi1>=-1.2); %narrow band of phi1
            inidx1 = find(phi1>=0); %phi1 frontground index
            outidx1 = find(phi1<0); %phi1 background index
            
            nb2 = find(phi2<1.2 & phi2>=-1.2); %narrow band of phi2
            inidx2 = find(phi2>=0); %phi2 frontground index
            outidx2 = find(phi2<0); %phi2 background index
            %-- End initiliazaions on narrow band
            
            %-- Mean calculations for different partitions
            %c11 = mean (phi1>0 & phi2>0)
            %c12 = mean (phi1>0 & phi2<0)
            %c21 = mean (phi1<0 & phi2>0)
            %c22 = mean (phi1<0 & phi2<0)
            
            cc11 = intersect(inidx1,inidx2); %index belong to (phi1>0 & phi2>0)
            cc12 = intersect(inidx1,outidx2); %index belong to (phi1>0 & phi2<0)
            cc21 = intersect(outidx1,inidx2); %index belong to (phi1<0 & phi2>0)
            cc22 = intersect(outidx1,outidx2); %index belong to (phi1<0 & phi2<0)
            
            f_image11 = 0;
            f_image12 = 0;
            f_image21 = 0;
            f_image22 = 0; % initial image force for each layer
            
            for i=1:layer
                L = im2double(P(:,:,i)); % get one image component
                
                if isempty(cc11)
                    c11 = eps;
                else
                    c11 = mean(L(cc11));
                end
                
                if isempty(cc12)
                    c12 = eps;
                else
                    c12 = mean(L(cc12));
                end
                
                if isempty(cc21)
                    c21 = eps;
                else
                    c21 = mean(L(cc21));
                end
                
                if isempty(cc22)
                    c22 = eps;
                else
                    c22 = mean(L(cc22));
                end
                
                %-- End mean calculation
                
                %-- Force calculation and normalization
                % force on each partition
                
                f_image11=(L-c11).^2.*HeavisideCV(phi1).*HeavisideCV(phi2)+f_image11;
                f_image12=(L-c12).^2.*HeavisideCV(phi1).*(1-HeavisideCV(phi2))+f_image12;
                f_image21=(L-c21).^2.*(1-HeavisideCV(phi1)).*HeavisideCV(phi2)+f_image21;
                f_image22=(L-c22).^2.*(1-HeavisideCV(phi1)).*(1-HeavisideCV(phi2))+f_image22;
            end
            
            % sum Image Force on all components (used for vector image)
            % if 'chan' is applied, this loop become one sigle code as a
            % result of layer = 1
            
            % calculate the external force of the image
            
            % curvature on phi1
            curvature1 = Params.LS_mu*kappa(phi1);
            curvature1 = curvature1(nb1);
            % image force on phi1
            fim1 = 1/layer.*(-f_image11(nb1)+f_image21(nb1)-f_image12(nb1)+f_image22(nb1));
            fim1 = fim1./max(abs(fim1)+eps);
            
            % curvature on phi2
            curvature2 = Params.LS_mu*kappa(phi2);
            curvature2 = curvature2(nb2);
            % image force on phi2
            fim2 = 1/layer.*(-f_image11(nb2)+f_image12(nb2)-f_image21(nb2)+f_image22(nb2));
            fim2 = fim2./max(abs(fim2)+eps);
            
            % force on phi1 and phi2
            force1 = curvature1+fim1;
            force2 = curvature2+fim2;
            %-- End force calculation
            
            % detal t
            dt = 1.5;
            
            old(:,:,1) = phi1;
            old(:,:,2) = phi2;
            
            %update of phi1 and phi2
            phi1(nb1) = phi1(nb1)+dt.*force1;
            phi2(nb2) = phi2(nb2)+dt.*force2;
            
            new(:,:,1) = phi1;
            new(:,:,2) = phi2;
            
            indicator = checkstop(old,new,dt);
            
            if indicator
%                 showphi(I, new, n);
                %make mask from SDF
                seg11 = (phi1>0 & phi2>0); %-- Get mask from levelset
                seg12 = (phi1>0 & phi2<0);
                seg13 = (phil>0 & phil2<0);
                seg21 = (phi1<0 & phi2>0);
                seg22 = (phi1<0 & phi2<0);
                
                se = strel('disk',1);
                aa1 = imerode(seg11,se);
                aa2 = imerode(seg12,se);
                aa3 = imerode(seg21,se);
                aa4 = imerode(seg22,se);
                aa5 = imerode(seg13,se);
                seg = aa1+2*aa2+3*aa3+4*aa4+aa5;
                
%                 subplot(2,2,4); imagesc(seg);axis ('image','off');title('Global Region-Based Segmentation');
                
                return
            end
            % re-initializations
            phi1 = reinitialization(phi1, 0.6);%sussman(phi1, 0.6);%
            phi2 = reinitialization(phi2, 0.6);%sussman(phi2,0.6);
        end
        phi(:,:,1) = phi1;
        phi(:,:,2) = phi2;
%         showphi(I, phi, n);
        %make mask from SDF
        seg11 = (phi1>0 & phi2>0); %-- Get mask from levelset
        seg12 = (phi1>0 & phi2<0);
        seg21 = (phi1<0 & phi2>0);
        seg22 = (phi1<0 & phi2<0);
        
        se = strel('disk',1);
        aa1 = imerode(seg11,se);
        aa2 = imerode(seg12,se);
        aa3 = imerode(seg21,se);
        aa4 = imerode(seg22,se);
        seg = aa1+2*aa2+3*aa3+4*aa4;
        %seg = bwlabel(seg);
        
%         subplot(2,2,4); imagesc(seg);axis ('image','off');title('Global Region-Based Segmentation');
        level_set=phi0; iter_to_converge=n;  % Prendre precedent level set pour etape suivante
        % write current level set to file every 'm_it'
        
        % % %
        % % % if( mod( ii - 1, m_it ) == 0 )
        % % %
        % % %     %   filename = strcat( name, 'levelset.png' );
        % % % %                   imwrite( phiO, filename );
        % % %     segim = createimage( u0, phi );
        % % %     filename = strcat( m_name, sprintf( '%06d', ( ( ii - 1 )/ m_it ) + 1 ), '.png' );
        % % %     imwrite( segim, filename );
        % % %   end;
        
end
