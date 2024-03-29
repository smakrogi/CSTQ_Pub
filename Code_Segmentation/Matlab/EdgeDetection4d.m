function EdgeImage=EdgeDetection4d(CurrentFrame,PreviousFrame,NextFrame,filtertype)
%syntax: EdgeImage=EdgeDetection4d(CurrentFrame,PreviousFrame,NextFrame,filtertype)
%filtertype: 1 for Sobel, 2 for Parzen
% S. Makrogiannis, MIVIC, PEMACS, DESU <smakrogiannis@desu.edu>

[height,width,nChannels]=size(CurrentFrame);
if nChannels == 1
    CurrentFrame=repmat(CurrentFrame,[1,1,3]);
    PreviousFrame=repmat(PreviousFrame,[1,1,3]);
    NextFrame=repmat(NextFrame,[1,1,3]);
end
CurrentFrame=double(CurrentFrame);
PreviousFrame=double(PreviousFrame);
NextFrame=double(NextFrame);
EdgeImage=zeros(height,width);

switch (filtertype)
    
case 1 %sobel
    
    % Spatial gradient estimates for the three channels.
    F1=fspecial('sobel');
    F2=F1';
    Gx1=imfilter(CurrentFrame(:,:,1),F1);
    Gy1=imfilter(CurrentFrame(:,:,1),F2);
    
    Gx2=imfilter(CurrentFrame(:,:,2),F1);
    Gy2=imfilter(CurrentFrame(:,:,2),F2);
    
    Gx3=imfilter(CurrentFrame(:,:,3),F1);
    Gy3=imfilter(CurrentFrame(:,:,3),F2);
    
    % Temporal gradient estimates for three channels (Sobel-like).
    a1p=1;,a2p=2;,a3p=1;,a1n=-1;,a2n=-2;,a3n=-1;
    for(i=2:height-1)
        for(j=2:width-1)
            Gt1(i,j)=a1p*PreviousFrame(i,j-1,1)+a2p*PreviousFrame(i,j,1)+...
                a3p*PreviousFrame(i,j+1,1)+...
                a1n*NextFrame(i,j-1,1)+a2n*NextFrame(i,j,1)+...
                a3n*NextFrame(i,j+1,1);

            Gt2(i,j)=a1p*PreviousFrame(i,j-1,2)+a2p*PreviousFrame(i,j,2)+...
                a3p*PreviousFrame(i,j+1,2)+...
                a1n*NextFrame(i,j-1,2)+a2n*NextFrame(i,j,2)+...
                a3n*NextFrame(i,j+1,2);

            Gt3(i,j)=a1p*PreviousFrame(i,j-1,3)+a2p*PreviousFrame(i,j,3)+...
                a3p*PreviousFrame(i,j+1,3)+...
                a1n*NextFrame(i,j-1,3)+a2n*NextFrame(i,j,3)+...
                a3n*NextFrame(i,j+1,3);
        end
    end
    
    % Fill the border values.
    Gt1(1,:)=Gt1(2,:);,Gt2(1,:)=Gt2(2,:);,Gt3(1,:)=Gt3(2,:);
    Gt1(height,:)=Gt1(height-1,:);,Gt2(height,:)=Gt2(height-1,:);,Gt3(height,:)=Gt3(height-1,:);
    Gt1(:,1)=Gt1(:,2);,Gt2(:,1)=Gt2(:,2);,Gt3(:,1)=Gt3(:,1);
    Gt1(:,width)=Gt1(:,width-1);,Gt2(:,width)=Gt2(:,width-1);,Gt3(:,width)=Gt3(:,width-1);
    
    % Estimate gradient magnitude.
    G=zeros(height,width,colors);
    G(:,:,1)= sqrt(Gx1.^2+Gy1.^2+Gt1.^2);
    G(:,:,2)= sqrt(Gx2.^2+Gy2.^2+Gt2.^2);
    G(:,:,3)= sqrt(Gx3.^2+Gy3.^2+Gt3.^2);    
    
    % Final gradient magnitude.
    EdgeImage=sqrt(sum(G.^2,3));
    EdgeImage=EdgeImage/max(max(EdgeImage));
    EdgeImage=uint8(255*EdgeImage);
    
case 2 %parzen

    Rdata=zeros(height,width,3);
    Gdata=zeros(height,width,3);
    Bdata=zeros(height,width,3);

    Rdata(:,:,1)=PreviousFrame(:,:,1);
    Rdata(:,:,2)=CurrentFrame(:,:,1);
    Rdata(:,:,3)=NextFrame(:,:,1);
    
    Gdata(:,:,1)=PreviousFrame(:,:,2);
    Gdata(:,:,2)=CurrentFrame(:,:,2);
    Gdata(:,:,3)=NextFrame(:,:,2);
    
    Bdata(:,:,1)=PreviousFrame(:,:,3);    
    Bdata(:,:,2)=CurrentFrame(:,:,3);    
    Bdata(:,:,3)=NextFrame(:,:,3);    
    
    win=3;
    if (deb)
         sig=input('Parzen Sigma (Usual value:20):');
    else
        sig=20;
    end
    h=(win-1)/2;

    for i=(1+h):(height-h)
        % i
        for j=(1+h):(width-h)
            xr=reshape(Rdata((i-h):(i+h),(j-h):(j+h),:),1,win*win*3);
            xg=reshape(Gdata((i-h):(i+h),(j-h):(j+h),:),1,win*win*3);
            xb=reshape(Bdata((i-h):(i+h),(j-h):(j+h),:),1,win*win*3);
            
            mxr=mean(xr);
            mxg=mean(xg);
            mxb=mean(xb);
      
            dr=(mxr-xr).^2+(mxg-xg).^2+(mxb-xb).^2;
            EdgeImage(i,j)=mean(exp(-dr/(2*sig^2)))/sig;
          
        end
    end
    EdgeImage=EdgeImage/max(max(EdgeImage));    
    EdgeImage=uint8(255*(1-EdgeImage));
    
end
    
    

