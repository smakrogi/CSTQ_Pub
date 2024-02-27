function    DFD=CalculateDFD(Frame1,Frame2)
%syntax: DFD=CalculateDFD(Frame1,Frame2)

Frame1=double(Frame1);
Frame2=double(Frame2);
DFD = sqrt(sum((Frame1-Frame2).^2,3));
DFD=DFD/max(DFD(:));