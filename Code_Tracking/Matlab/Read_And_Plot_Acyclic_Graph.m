function Acyclic_Graph_Table = Read_And_Plot_Acyclic_Graph

% Choose file.
[graph_table_filename, path_name] = uigetfile('*.txt', ...
    'Select tracking graph file', 'MultiSelect', 'off');

if isequal(graph_table_filename,0)
   disp('User selected Cancel')
   Acyclic_Graph_Table = [];
   return;
else
   disp(['User selected ', fullfile(path_name, graph_table_filename)])
end

% Retrieve sequence name from filename.
string_cell = strsplit(path_name, filesep);
cell_length = length(string_cell);
sequence_name = [string_cell{cell_length-3}, ...
    '_', string_cell{cell_length-2}];

% Read-in the acyclic graph table.
% Acyclic_Graph_Table = textread(fullfile(path_name, graph_table_filename), '%d %d %d %d');
Acyclic_Graph_Table = dlmread(fullfile(path_name, graph_table_filename), ' ');

% Plot acyclic graph table.
Plot_Acyclic_Graph(Acyclic_Graph_Table, sequence_name);

end