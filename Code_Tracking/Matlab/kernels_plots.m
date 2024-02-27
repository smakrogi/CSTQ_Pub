hname = {'normal' 'box' 'epanechnikov' 'triangle' };
colors = {'c' 'b' 'g' 'r'};
lines = {'-','-.','--',':'};

% Generate a sample of each kernel smoothing function and plot
data = [0];
figure
for j=1:4
    pd = fitdist(data,'kernel','Kernel',hname{j});
    x = -4:.1:4;
    y = pdf(pd,x);
    plot(x,y,'Color',colors{j},'LineStyle',lines{j},'LineWidth',2)
    hold on;
end
legend(hname{:})
hold off