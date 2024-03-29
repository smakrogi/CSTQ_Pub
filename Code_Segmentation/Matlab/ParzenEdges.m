function y=ParzenEdges(x,win,sig)
%syntax: y=ParzenEdges(x,win,sig)
%x: input color image 3D or 2D matrix
%win: the size of the window
%sig: the h of the potential

%#realonly

x=double(x);
[height, width, nChannels] = size(x);
siz = [height, width, nChannels];
y=zeros([siz(1) siz(2)]);
h=(win-1)/2;

x=double(x);

switch siz(3)
case 1
    
    for i=(1+h):(siz(1)-h)
        % i
        for j=(1+h):(siz(2)-h)
            xr=reshape(x((i-h):(i+h),(j-h):(j+h),1),1,win*win);
            
            mxr=mean(xr);
            
            dr=(mxr-xr).^2;
            
            y(i,j)=mean(exp(-dr/(2*sig^2)))/sig;
            
        end
    end
    
case 3
    for i=(1+h):(siz(1)-h)
        % i
        for j=(1+h):(siz(2)-h)
            xr=reshape(x((i-h):(i+h),(j-h):(j+h),1),1,win*win);
            xg=reshape(x((i-h):(i+h),(j-h):(j+h),2),1,win*win);
            xb=reshape(x((i-h):(i+h),(j-h):(j+h),3),1,win*win);
            mxr=mean(xr);
            mxg=mean(xg);
            mxb=mean(xb);
            
            dr=(mxr-xr).^2+(mxg-xg).^2+(mxb-xb).^2;
            
            y(i,j)=mean(exp(-dr/(2*sig^2)))/sig;
            
        end
    end
    
end





%fill border values
for j=1:siz(2)
    i=1;
    for k=0:h-1
        y(i+k,j)=y(i+h,j);
    end
end

for j=1:siz(2)
    i=siz(1);
    for k=0:h-1
        y(i-k,j)=y(i-h,j);
    end
end

for i=1:siz(1)
    j=1;
    for k=0:h-1
        y(i,j+k)=y(i,j+h);
    end
end

for i=1:siz(1)
    j=siz(2);
    for k=0:h-1
        y(i,j-k)=y(i,j-h);
    end
end





%normalize values

MIN=min(min(y));
MAX=max(max(y));
y=(y-MIN)/(MAX-MIN);
%y=y/MAX;
