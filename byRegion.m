% Load data
% spike_times = readNPY('spikes.times.npy');
% spike_clusters = readNPY('spikes.clusters.npy');
% clusters_brainLocation = readtable('channels.brainLocation.tsv', 'FileType', 'text', 'Delimiter', '\t');
% cluster_peakChannel = readNPY('clusters.peakChannel.npy');

rootDir = './allData';
    if ~isempty(rootDir)
        d = dir(fullfile(rootDir, '*')); 
        d = d([d.isdir]); 
        sessionNames = {d.name}; 
        sessionNames = sessionNames(~strcmp(sessionNames, '.') & ~strcmp(sessionNames,'..')); 
        indx = listdlg('ListString',sessionNames, 'Name', 'Select a session');
    
        if ~isempty(indx)
            
            % load session 
            s = loadSession(fullfile(rootDir, sessionNames{indx}));
        end
    end
spike_times = s.spikes.times;
spike_clusters = s.spikes.clusters;
clusters_brainLocation = s.channels.brainLocation;
cluster_peakChannel = s.clusters.peakChannel;


% Get unique cluster IDs
unique_clusters = unique(spike_clusters);

% Get unique brain regions
unique_brain_regions = unique(clusters_brainLocation.allen_ontology, 'rows');

% Initialize a structure to store spike times organized by brain region
brain_region_spike_times = struct();

% Iterate over brain regions
for region_idx = 1:numel(unique_brain_regions)
    region = unique_brain_regions(region_idx);
    region_spike_times = {};

    % Iterate over unique clusters
    for cluster_idx = 1:numel(unique_clusters)
        cluster_id = unique_clusters(cluster_idx);
        peak_channel = cluster_peakChannel(cluster_idx);
        cluster_brain_region = clusters_brainLocation.allen_ontology(peak_channel);

        % Check if cluster's brain region matches the current region
        if strcmp(region, cluster_brain_region)
            % Extract spike times for the current cluster
            cluster_spike_times = spike_times(spike_clusters == cluster_id);

            % Append the cluster spike times to the region_spike_times cell array
            region_spike_times{end+1} = cluster_spike_times;
        end
    end

    % Replace any non-alphanumeric characters with underscores
    valid_field_name = ['r', regexprep(region, '[^a-zA-Z0-9]', '_')];


    % Store region_spike_times in the brain_region_spike_times structure
    brain_region_spike_times.(valid_field_name) = region_spike_times;
end

% The brain_region_spike_times structure now contains separate matrices
% for each brain region, with each matrix containing relevant clusters and their spike times.
