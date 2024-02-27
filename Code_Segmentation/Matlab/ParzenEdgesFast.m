function edge_density_image = ParzenEdgesFast(input_image,pkl,pb)
%syntax: y=ParzenEdges(x,win,sig)
%x: input color image 3D or 2D matrix
%win: the size of the window
%sig: the h of the potential

%#realonly

input_image = double(input_image);
matrix_size = size(input_image);
edge_density_image = zeros([matrix_size(1) matrix_size(2)]);
pkhl = (pkl-1)/2;

input_image = double(input_image);

switch numel(matrix_size)
    case 2
        kde_fun = @(block) KDE(block, pb);
        
        edge_density_image = colfilt(input_image, [pkl pkl], 'sliding', kde_fun);
    case 3
        for i=(1+pkhl):(matrix_size(1)-pkhl)
            % i
            for j = (1+pkhl):(matrix_size(2)-pkhl)
                xr = reshape(input_image((i-pkhl):(i+pkhl),(j-pkhl):(j+pkhl),1),1,pkl*pkl);
                xg = reshape(input_image((i-pkhl):(i+pkhl),(j-pkhl):(j+pkhl),2),1,pkl*pkl);
                xb = reshape(input_image((i-pkhl):(i+pkhl),(j-pkhl):(j+pkhl),3),1,pkl*pkl);
                mxr = mean(xr);
                mxg = mean(xg);
                mxb = mean(xb);
                
                dr = (mxr-xr).^2+(mxg-xg).^2+(mxb-xb).^2;
                
                edge_density_image(i,j) = mean(exp(-dr/(2*pb^2)))/pb;
                
            end
        end
end

%fill border values
for j=1:matrix_size(2)
    i=1;
    for k=0:pkhl-1
        edge_density_image(i+k,j)=edge_density_image(i+pkhl,j);
    end
end

for j=1:matrix_size(2)
    i=matrix_size(1);
    for k=0:pkhl-1
        edge_density_image(i-k,j)=edge_density_image(i-pkhl,j);
    end
end

for i=1:matrix_size(1)
    j=1;
    for k=0:pkhl-1
        edge_density_image(i,j+k)=edge_density_image(i,j+pkhl);
    end
end

for i=1:matrix_size(1)
    j=matrix_size(2);
    for k=0:pkhl-1
        edge_density_image(i,j-k)=edge_density_image(i,j-pkhl);
    end
end

%normalize values
MIN=min(min(edge_density_image));
MAX=max(max(edge_density_image));
edge_density_image=(edge_density_image-MIN)/(MAX-MIN);
%y=y/MAX;

end

function p = KDE(xr, pbw)
mxr=mean(xr);
dr=(mxr-xr).^2;
p = mean(exp(-dr/(2*pbw^2)))/pbw;
end