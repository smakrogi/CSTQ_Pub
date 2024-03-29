function [Iref, indexIref] = info_from_cursor(Histo_Vector,bins,Nom)

fig_Hist   = figure;
plot(bins,Histo_Vector,'Color','black','LineWidth',2);
titlestring=['Histogram of all the frames of',Nom,' dataset'];
title(titlestring,'color','k','FontSize',14,'FontWeight','bold','Color','b','FontName','Time New Roman');
xlabel('Intensity','FontSize',14,'FontWeight','bold'); 
ylabel('Occurrence frequency','FontSize',14,'FontWeight','bold');
%set(gca,'xscale','log');
grid on; grid minor;

dcm_obj    = datacursormode(fig_Hist);
set(dcm_obj,'DisplayStyle','datatip',...
    'SnapToDataVertex','off','Enable','on')
% % % fig_name  = strcat('C:\Users\Public\histo all 5 11 2015\',Nom,'histoall.fig');
% % % saveas(gcf,fig_name);
% % % 
% % % fig_name  = strcat('C:\Users\Public\histo all 5 11 2015\',Nom,'histoall.png');
% % % saveas(gcf,fig_name);
disp('Choose the end background intensity of the histogram then press Return.')
% Wait while user is choosing the background limit
pause

c_info     = getCursorInfo(dcm_obj);
Iref       = round(c_info.Position(1));
nBins = numel(bins);
indices = 1:nBins;
[minValue, indexIref] = min(abs(bins - Iref));
indexIref = indexIref(1) - 1;
x          = Iref;
y          = round(c_info.Position(2));
str        = strcat(num2str(x));

% Annotate the point
text(x,y,'\leftarrow Iref= ','HorizontalAlignment','left');
text(x+10,y,str,'HorizontalAlignment','left');
set(c_info.Target,'Color','blue','LineWidth',2)

%txt = {['Iref ',num2str(c_info.DataIndex)]};
%set(c_info.Target,'Color','blue','Width',2)

% % % fig_name  = strcat('C:\Users\Public\histo all 5 11 2015\',Nom,'_background.fig');
% % % saveas(gcf,fig_name);