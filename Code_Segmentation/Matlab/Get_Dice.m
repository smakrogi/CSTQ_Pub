function [Dice] =Get_Dice(Reference,Seg)
% Takes the segmented image and the reference image (should be binarized) 
% returns the Dice coefficient 
% used for quantifying the accuracy of 2D image segmentation DICE similarity (see wikipedia):               
%      Dice Coef = 2*intersect(A,B)/(absolute(A)+absolute(B))
 
% if mean(mean(Seg))>0.5
%     Seg=1-Seg;
% end    
intersection =  sum(Reference(:) & Seg(:)); 
abs_Ref      =  sum(Reference(:)); 
absseg       =  sum(Seg(:));
Dice         =  (2*intersection)/(abs_Ref + absseg);
