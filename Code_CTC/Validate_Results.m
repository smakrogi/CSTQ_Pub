%% Data location and information.
if ispc
    user_folder = getenv('USERPROFILE');
else
    user_folder = getenv('HOME');
end

% Root folder for data.
data_folder = fullfile(user_folder,'Documents','Data','Cell_Tracking_Challenge','Training');

measure_types = {'SEGMeasure ', 'DETMeasure '}; % , 'TRAMeasure '

data_string = {'Fluo-C2DL-MSC', 'Fluo-N2DH-GOWT1', ...
    'Fluo-N2DL-HeLa', 'Fluo-N2DH-SIM+', ...
    'DIC-C2DH-HeLa','Fluo-C2DL-Huh7', ...
    'PhC-C2DH-U373','PhC-C2DL-PSC'};

for ii=1:numel(measure_types)
    fprintf('%s\n',measure_types{ii});
    for jj=1:numel(data_string)
        fprintf('%s 01\t', data_string{jj});
        system([measure_types{ii}, fullfile(data_folder, data_string{jj}), ' 01 3']);
        fprintf('%s 02\t', data_string{jj});
        system([measure_types{ii}, fullfile(data_folder, data_string{jj}), ' 02 3']);
    end
end

