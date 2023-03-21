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

nProbe = 1;
inclCID = find(s.clusters.probes==nProbe-1)-1;
coords = s.channels.sitePositions(s.channels.probe==nProbe-1,:);
acr = s.channels.brainLocation.allen_ontology(s.channels.probe==nProbe-1,:);
lowerBorder = 0; upperBorder = []; acronym = {acr(1,:)};
for q = 2:size(acr,1)
    if ~strcmp(acr(q,:), acronym{end})
        upperBorder(end+1) = coords(q,2); 
        lowerBorder(end+1) = coords(q,2); 
        acronym{end+1} = acr(q,:);
    end
end
upperBorder(end+1) = max(coords(:,2));
upperBorder = upperBorder'; lowerBorder = lowerBorder'; acronym = acronym';
anatData = struct('borders', table(upperBorder, lowerBorder, acronym));

spike_times = s.spikes.times;
spike_clusters = s.spikes.clusters;

% Get unique cluster IDs
unique_clusters = unique(spike_clusters);

% Get unique brain regions
unique_brain_regions = unique(anatData.borders.acronym);

% Initialize a structure to store spike times organized by brain region
brain_region_spike_times = struct();

% Iterate over brain regions
for region_idx = 1:numel(unique_brain_regions)
    region = unique_brain_regions{region_idx};
    region_spike_data = struct();

    % Iterate over unique clusters
    for cluster_idx = 1:numel(unique_clusters)
        cluster_id = unique_clusters(cluster_idx);
        
        % Find the channel associated with the current cluster
        channel_idx = s.clusters.peakChannel(cluster_id+1);
        channel_coord = s.channels.sitePositions(channel_idx, :);

        % Find the brain region for the current cluster
        cluster_brain_region_idx = find(anatData.borders.lowerBorder <= channel_coord(2) & anatData.borders.upperBorder > channel_coord(2));
        cluster_brain_region = anatData.borders.acronym{cluster_brain_region_idx};

        % Check if cluster's brain region matches the current region
        if strcmp(region, cluster_brain_region)
            % Extract spike times for the current cluster
            cluster_spike_times = spike_times(spike_clusters == cluster_id);

            % Store the cluster number and its associated spiking data in the nested structure
            cluster_data = struct('cluster_id', cluster_id, 'spike_times', cluster_spike_times);
            region_spike_data.(['cluster_' num2str(cluster_id)]) = cluster_data;
        end
    end

    % Replace any non-alphanumeric characters with underscores
    valid_field_name = regexprep(region, '[^a-zA-Z0-9]', '');

    % Store region_spike_data in the brain_region_spike_times structure
    brain_region_spike_times.(valid_field_name) = region_spike_data;
end

% The brain_region_spike_times structure now contains separate nested structures
% for each brain region, with each nested structure containing the cluster number
% and its associated spiking data.
