function feature_table = ReadAndPlotForegroundBackgroundFeatures(Nom,Params)
% S. Makrogiannis, MIVIC, PEMACS, DESU <smakrogiannis@desu.edu>

feature_table = readtable(strcat('ST-feature-computation-',Nom,'.csv'));

num_cols = numel(feature_table.Properties.VariableNames);

group = table2array(feature_table);
group = group(:,1:num_cols-1);

Label = feature_table.label;
xnames = feature_table.Properties.VariableNames(1:num_cols-1);

if Params.display
    figure(2);
    gplotmatrix(group,[],Label,[],[],[],[],'hist',xnames);
    title('Foreground and Background Features of ST frames')
    saveas(gcf, strcat('ST-feature-computation-plot-',Nom,'.fig'))
end

end