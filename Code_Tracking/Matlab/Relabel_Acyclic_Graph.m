function RelabeledAcyclic_Graph_Table = Relabel_Acyclic_Graph(Acyclic_Graph_Table)

n_rows = size(Acyclic_Graph_Table, 1);
RelabeledAcyclic_Graph_Table = Acyclic_Graph_Table;

% For each row:
for i=1:n_rows
    I = Acyclic_Graph_Table(:,4) == Acyclic_Graph_Table(i, 1);
    RelabeledAcyclic_Graph_Table(i, 1) = i;
    RelabeledAcyclic_Graph_Table(I, 4) = i;
end

end
