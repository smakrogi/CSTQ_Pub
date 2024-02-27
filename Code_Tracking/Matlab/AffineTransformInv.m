function B=AffineTransformInv(A,Params);
%syntax: B=AffineTransformInv(A,Params);
% uses the inverse affine mapping parameters calculated by
% our registration method.
%  Created by: Sokratis Makrogiannis, 04/2004.

a=Params(1);
b=Params(2);
c=Params(3);
d=Params(4);
e=Params(5);
f=Params(6);

[rows cols z]=size(A);

B=zeros(rows,cols); 

index_i = zeros(size(A));

index_j = zeros(size(A));


for (i=1:rows)
    for(j=1:cols)
        
        index_i(i,j)=a*i+b*j+c;
        %index_i=round(index_i);
        index_j(i,j)=d*i+e*j+f;
        %index_j=round(index_j);
        
%         if(index_i>0 & index_j>0 & index_i<=rows & index_j<=cols)
%             B(i,j)=A(index_i,index_j);
%         end
        
    end
end


B = linint2D2(index_i, index_j, double(A));
