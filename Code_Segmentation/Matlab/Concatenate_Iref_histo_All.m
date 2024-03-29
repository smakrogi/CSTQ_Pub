function [Iref_or_Itest,CDF_Iref_or_Itest,Maxi,Mini]=...
    Concatenate_Iref_histo_All(Training_data,Nom,lim1,lim2,Iref_or_neg,CDF_Iref_or_neg,Params)
% Training_data: cell array x{i}
% lim1, lim2: contains limits of the training data to process which
% gives us the number of frames
% F. Boukari, MIVIC, PEMACS, DESU
% S. Makrogiannis, MIVIC, PEMACS, DESU <smakrogiannis@desu.edu>

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               Training stage                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % 1. Concatenate all the frames vectors of the sequence
% % % 2. Compute Global Maximum and minimum values of all pixels all frames for scaling
% % % 3. Find the normalized histogram using 2^n bins (PMF).
% % % 4. Find the I ref in histogram which is the elbow Iref in the
% histogram which is the end of background 
%%%%%for the foreground background separation
% % % 5. Compute the CDF cumsum and find the percentile of the I ref
% example: 80% CDF_Iref
% % % 6. Scale the frames 0 to 255 linearly using Global max and Global min

Nb_Frames    = lim2-lim1+1;   % numel(Training_data);

if Nb_Frames ~= 1
    [M,N]        = size(Training_data{1}); % All frames have the same size
    Size_Of_All  = M*N*Nb_Frames;
    All_Frames   = zeros(Size_Of_All,1);
    Maxi         = 0;
    Mini         = min(min(double(Training_data{lim1})));
    for k = 1:Nb_Frames
        Frame    = double(Training_data{k+lim1-1});
        All_Frames((k-1)*M*N + 1 : k*M*N) = Frame(:);
        Maxi     = max(Maxi,max(max(Frame(:))));
        Mini     = min(Mini,min(min(Frame(:))));
        %whos if class='uint8' k=8  E=0:(2^k)-1;   if class uint16 diff nb bins
    end
else
    Frame    = double(Training_data);
    All_Frames = Frame(:);
    Maxi     = max(Frame(:));
    Mini     = min(Frame(:));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[Hist_V, lBins]       = histcounts(All_Frames, 2^10);
Norm_Hist_V  = Hist_V/sum(Hist_V);
Cum_Hist_V   = cumsum(Norm_Hist_V);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ( Iref_or_neg == -1 && isempty(CDF_Iref_or_neg))
    [Iref_or_Itest, index_Iref_or_Itest]         =  info_from_cursor(Hist_V,lBins,Nom);  % plots histograms each diff figure
    CDF_Iref_or_Itest       =  Cum_Hist_V(index_Iref_or_Itest+1); % begin from 1 instead of 0
else
    difference              =  abs(Cum_Hist_V - CDF_Iref_or_neg);
    I_t                     =  find(difference ==  min(difference));    %  round(Iref_Percent_cdf));   %
    index_Iref_or_Itest     =  I_t(1) -1;
    CDF_Iref_or_Itest       =  Cum_Hist_V(index_Iref_or_Itest+1); % begin by 1 instead of 0
    Iref_or_Itest           =  lBins(index_Iref_or_Itest+1);
end

if Params.display
    % Plot histogram of every 50th frame
    % Plot all different histograms
    figure(1)
    subplottight(3,8,1);plot(lBins(2:end),Hist_V,'LineWidth',2); hold on;
    plot(Iref_or_Itest, Hist_V(index_Iref_or_Itest+1), '*g');
    set(gca,'xscale','log');
    titlestring=[num2str(Nb_Frames),' Frames ', Nom,' Max=',num2str(Maxi),' Min=',num2str(Mini)];
    title(titlestring,'FontSize',10);
    xlabel('Intensity','FontSize',10); ylabel('Occurrences','FontSize',10);%frequencey occurrence
    grid on; grid minor;
    
    subplottight(3,8,2),plot(lBins(2:end),Norm_Hist_V); hold on;
    plot(Iref_or_Itest, Norm_Hist_V(index_Iref_or_Itest+1), '*g');
    title('PMF','FontSize',10);
    xlabel('Intensity','FontSize',10);
    ylabel('Probability','FontSize',10);
    %set(gca,'xscale','log');
    grid on; grid minor;
    
    plot(lBins(2:end),Cum_Hist_V,'LineWidth',2); hold on;
    plot(Iref_or_Itest, Cum_Hist_V(index_Iref_or_Itest+1), '*g');
    title('CDF','FontSize',10);
    xlabel('Intensity','FontSize',10);ylabel('Cumulative Prob.','FontSize',10);
    %set(gca,'xscale','log');
    grid on; grid minor;
    hold off;
end

