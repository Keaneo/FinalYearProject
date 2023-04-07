rootDir = './allData';
nProbe = 1;
region_names = ["MOs", "ACA"]; % Add more region names if desired
start_time = 65;
end_time = 75;

[s, sessionName] = load_session(rootDir);
anatData = prepare_anat_data(s, nProbe);
brain_region_spike_times = sort_spikes(s, anatData, sessionName);

valid_region_names = cell(1, numel(region_names));

for i = 1:numel(region_names)
    valid_region_names{i} = regexprep(region_names{i}, '[^a-zA-Z0-9]', '');
    if ~isfield(brain_region_spike_times, valid_region_names{i})
        error('One of the specified region_names was not found in the brain_region_spike_times struct.');
    end
end

hold on;

total_regions = numel(region_names);
current_row = 1;

for i = 1:total_regions
    region = brain_region_spike_times.(valid_region_names{i});
    
    % Add an offset for each region so that they don't overlap on the same plot
    row_offset = (i - 1) * current_row;
    plot_spikes(region, region_names{i}, s, start_time, end_time, row_offset);
    current_row = current_row + numel(fieldnames(region));
end
plot_events(s, start_time, end_time, current_row);

hold off;
