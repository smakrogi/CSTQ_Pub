function Plot_Acyclic_Graph(Acyclic_Graph_Table, sequence_name)
% Create a cell lineage tree using the graph table.

% Create figure.
figure('Position', [100, 100, 1600, 800]);
hold on;

% Relabel in increasing order starting from 1.
Acyclic_Graph_Table = Relabel_Acyclic_Graph(Acyclic_Graph_Table);

% Get parent labels (tree nodes).
parents = Acyclic_Graph_Table(:,4);

% Create tree layout and get the x-axis indices from the tree.
[x_index, ~, ~] = treelayout(parents);
x_index = x_index';


% line([Acyclic_Graph_Table(:,1), Acyclic_Graph_Table(:,1)]', ...
% [Acyclic_Graph_Table(:,2), Acyclic_Graph_Table(:,3)]', 'linestyle', '-', 'color', 'b', 'linewidth', 2);
line([x_index, x_index]', ...
    [Acyclic_Graph_Table(:,2), Acyclic_Graph_Table(:,3)]', 'linestyle', '--', 'color', [0,0.4,0], 'linewidth', 2);

% Fourth column: parent trajectory link.
n_rows = size(Acyclic_Graph_Table, 1);
for i=1:n_rows
    parent_label = Acyclic_Graph_Table(i,4);
    if parent_label ~= 0
        parent_last_frame = Acyclic_Graph_Table(parent_label, 3);
        %         line([Acyclic_Graph_Table(i,1); parent_label], ...
        % [Acyclic_Graph_Table(i,2); parent_last_frame], 'linestyle' , '--', 'color', 'g', 'linewidth', 2);
        line([x_index(i); x_index(parent_label)], ...
            [Acyclic_Graph_Table(i,2); parent_last_frame], 'linestyle' , '-', 'color', 'b', 'linewidth', 2);
        % text(x_index(i), Acyclic_Graph_Table(i,2)+1, num2str(i), 'fontsize', 8)
    end
end

% First column: trajectory label (x-axis) use previous x-axis coordinates.
% Second column: first frame (y-axis)
% plot(Acyclic_Graph_Table(:,1), Acyclic_Graph_Table(:,2), 'o', 'linewidth', 2);
plot(x_index, Acyclic_Graph_Table(:,2), 'o', 'linewidth', 2, 'MarkerEdgeColor','k',...
                'MarkerFaceColor',[.49 1 .63], 'MarkerSize',6);
text(x_index, Acyclic_Graph_Table(:,2)+1, num2str(Acyclic_Graph_Table(:,1)), 'fontsize', 8, 'fontweight', 'bold')

% Third colummn: last frame (y-axis) link with second column.
% plot(Acyclic_Graph_Table(:,1), Acyclic_Graph_Table(:,3), 'o', 'linewidth', 2);
plot(x_index, Acyclic_Graph_Table(:,3), 's', 'linewidth', 2, 'MarkerEdgeColor','k',...
                'MarkerFaceColor',[0.8 0.7 0], 'MarkerSize',6);
% text(x_index, Acyclic_Graph_Table(:,3)+1,num2str(Acyclic_Graph_Table(:,1)), 'fontsize', 8)

% Set labels and title.
set(gca,'xtick',[],'box','on','gridlinestyle','-','minorgridlinestyle',':');
ylabel('Frame number', 'fontsize', 12);
xlabel('Cell tracks', 'fontsize', 12);
title(['Cell lineage tree for ', sequence_name], 'fontsize', 16, 'Interpreter', 'none');

% Reverse y-axis.
axis ij;
grid(gca,'minor'); 
set(gca,'xtick',[]);
set(gca,'xticklabel',[]);
xlabel('Cell ID', 'fontsize', 14);
hold off;

% Write figure to file.
saveas(gcf, ['cell_lineage_tree_', sequence_name, '.png']);
saveas(gcf, ['cell_lineage_tree_', sequence_name, '.fig']);
end