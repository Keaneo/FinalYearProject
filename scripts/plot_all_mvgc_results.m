path = './processed/pvalues/';
rootDir = './allData/';

% Get a list of all the files in the directory
files = dir(fullfile(path, '*.mat'));

% Loop through each file and load it
for i = 1:1
    file = files(i);
    filename = fullfile(path, file.name);
    data = load(filename);
    [s, sessionName] = load_session(rootDir, i);
    nProbe = 1;
    anatData = prepare_anat_data(s, nProbe);
    
    region_names = unique(anatData.borders.acronym);

    plot_coloured_matrix(data.pvalues,  [1, 0, 0], [0, 0, 1], 0, region_names, flip(region_names));
    saveas(gcf, strcat('./graphs/' ,sessionName, '.png'), 'png');
end
