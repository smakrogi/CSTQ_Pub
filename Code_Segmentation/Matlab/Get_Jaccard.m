function Jaccard = Get_Jaccard(Reference ,Seg)
% Takes the segmented image and the reference image (should be binarized) 
% returns the Jaccard
% used for quantifying the accuracy of 2D image segmentation Jaccard index               
%      Jaccard = intersect(A,B) / union(A,B)
 
% if mean(mean(Seg))>0.5
%     Seg=1-Seg;
% end    
intersection =  sum(Reference(:) & Seg(:)); 
union        =  sum(Reference(:) | Seg(:)); 
Jaccard      =  intersection / union;
