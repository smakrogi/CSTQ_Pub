function A1=ShowRegions(A,L)
% This function creates the label image that shows clearly
% the boundaries of regions 

%#realonly

[height,width,c]=size(A);

 for i=1:height
    for j=1:width
      
       if L(i,j)==0
         A(i,j,:)=1;
       end
       
    end
 end
 
 A1=A;


      
      