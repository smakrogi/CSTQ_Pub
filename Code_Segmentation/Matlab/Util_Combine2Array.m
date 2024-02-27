% Combinatinon Two String Cells A, B
function Result=Util_Combine2Array(A,B)
        % e.g.
        %A=[1,2,3];
        %B=[4,5,6];
        
        %Linearlize
        m=size(A,1)*size(A,2)
        n=size(B,1)*size(B,2)
  
        %Combination Result
        Result={}
        k = 1;
        for i=1:m
            for j=1:n
                % Cobine 2 String cell
                Result{k}= A{i}+ " " + B{j};
                k=k+1;
            end
        end

      