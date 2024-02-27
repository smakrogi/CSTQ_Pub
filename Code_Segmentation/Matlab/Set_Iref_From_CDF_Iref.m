function [Iref, Matched_CDF_Iref] = Set_Iref_From_CDF_Iref(Input_Frame, CDF_Iref, Params)
% syntax: [Iref, Matched_CDF_Iref] = Set_Iref_From_CDF_Iref(All_Frames,
% CDF_Iref);
% Find reference intensity corresponding to CDF reference value.
% S. Makrogiannis, MIVIC, PEMACS, DESU <smakrogiannis@desu.edu>

% Compute histogram, normalize, get cdf, and match cdf_iref.
Input_Frame = Input_Frame(:);
nbins = min(numel(Input_Frame), 2^14);
[Norm_Hist_V, edges] = histcounts(Input_Frame, nbins, 'Normalization', 'probability');
Cum_Hist_V = cumsum(Norm_Hist_V);
difference =  abs(Cum_Hist_V - CDF_Iref);
I_t = find(difference ==  min(difference));
index_Iref = I_t(1);
if index_Iref == 1, index_Iref = 2; end
Matched_CDF_Iref = Cum_Hist_V(index_Iref); % begin from 1 instead of 0
Iref = edges(index_Iref);

% Display results.
if Params.display
    rbins = edges(2:end);
    figure(1); 
%     subplottight(3,4,4); plot(rbins,Norm_Hist_V); hold on
%     plot(Iref, Norm_Hist_V(index_Iref), '*g'); hold off;
%     title('Motion Activity PMF','FontSize',10);
%     xlabel('Intensity','FontSize',10);
%     ylabel('Probability','FontSize',10);
%     grid on; grid minor;
    subplottight(3,4,4); plot(rbins,Cum_Hist_V); hold on;
    plot(Iref, Matched_CDF_Iref, '*g'); hold off;
    title('Motion Activity CDF','FontSize',10);
    xlabel('Intensity','FontSize',10);
    ylabel('Probability','FontSize',10);
    grid on; grid minor;
end
