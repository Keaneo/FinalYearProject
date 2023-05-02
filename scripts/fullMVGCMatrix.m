% Set the directory where the .mat files are stored
path = './processed/pvalues/';
rootDir = './allData/';

% Initialize a cell array to store the pvalues matrices
pvalues_matrices = {};

% Initialize two cell arrays to store the region names and flipped region names
region_names_list = {};
flipped_region_names_list = {};

% Get a list of all the files in the directory
files = dir(fullfile(path, '*.mat'));

% Loop through each file and load it
for i = 1:length(files)
    file = files(i);
    filename = fullfile(path, file.name);
    data = load(filename);
    [s, sessionName] = load_session(rootDir, i);
    nProbe = 1;
    anatData = prepare_anat_data(s, nProbe);
    
    % Add the pvalues matrix to the cell array
    pvalues_matrices{i} = data.pvalues;
    
    % Add the region names to the region_names_list
    region_names_list{i} = unique(anatData.borders.acronym);
    
    % Add the flipped region names to the flipped_region_names_list
    flipped_region_names_list{i} = flip(region_names_list{i});
end

% Plot the first pvalues matrix with its corresponding region names and flipped region names
plot_meta_matrix(pvalues_matrices, [1, 0, 0], [0, 0, 1], 0, region_names_list, flipped_region_names_list);
