%load session
rootDir = './allData';
if ~isempty(rootDir)
    d = dir(fullfile(rootDir, '*')); 
    d = d([d.isdir]); 
    sessionNames = {d.name}; 
    sessionNames = sessionNames(~strcmp(sessionNames, '.') & ~strcmp(sessionNames,'..')); 
    indx = listdlg('ListString',sessionNames, 'Name', 'Select a session');

    if ~isempty(indx)
        s = loadSession(fullfile(rootDir, sessionNames{indx}));
    end
end

% taken from eventRasters.m
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



% Check if spikes have been sorted, if not, sort them
filename = strcat('processed/spike_times_by_region', sessionNames{indx} ,'.mat');
if exist(filename, 'file') == 2
    fprintf('Spikes already sorted by region\n');
    load(filename);
else
    fprintf('Spikes not sorted, sorting...\n');
    % Initialize a structure to store spike times organized by brain region
    brain_region_spike_times = struct();
    % SORT SPIKES BY REGION
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
        save(strcat('processed/spike_times_by_region', sessionNames{indx} ,'.mat'), "brain_region_spike_times");
    end
    fprintf('Spikes Sorted!');
end

%===========
region_name = "MOs";
if isfield(brain_region_spike_times, region_name)
    % Get the corresponding struct
    region = brain_region_spike_times.(region_name);
else
    error('The specified region_name was not found in the brain_region_spike_times struct.');
end
%===========

% Initialize an empty matrix to store line data
line_data = [];

% Set range of times to plot
start_time = 0;
end_time = 20;

% Iterate through all the fields in the "region" struct
field_names = fieldnames(region);
for k = 1:numel(field_names)
    % Get the cluster struct from "region"
    cluster_struct = region.(field_names{k});

    % Iterate through all the named vectors in the current cluster struct
    cluster_field_names = fieldnames(cluster_struct);
    
        % Get the named vector
        cluster_name = cluster_field_names{2};
        cluster_vector = cluster_struct.(cluster_name);

        % Iterate through all the elements in the named vector
        num_elements = numel(cluster_vector);
        for i = 1:num_elements
            if cluster_vector(i) >= start_time && cluster_vector(i) <= end_time
                % Store the line data for each element in the named vector
                line_data = [line_data; cluster_vector(i) k k+1];
            end
        end
    
end




% Plot all lines at once using the plot function
plot([line_data(:, 1) line_data(:, 1)]', [line_data(:, 2) line_data(:, 3)]', 'k-');
hold on;



for j = 1:numel(s.trials.goCue_times)
    if(s.trials.goCue_times(j) >= start_time && s.trials.goCue_times(j) <= end_time)
        line([s.trials.goCue_times(j) s.trials.goCue_times(j)], [0 max(max(line_data, [], 2))]);
    end
end
% Customize the plot appearance (optional)
xlabel('Time (s)');
ylabel('Cluster Number');
title(strcat("Spike Times in ", region_name));
grid on;

% Release the hold on the plot
hold off;
