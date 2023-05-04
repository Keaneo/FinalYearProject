% Used to loop all sessions and sort spiking data
function trigger_sorting(rootDir, sessionIndx)

    %Load Session from Steinmetz dataset
    [s, sessionName] = load_session(rootDir, sessionIndx);
    nProbe = 1;
    anatData = prepare_anat_data(s, nProbe);
    
    % Sort the data into region by cluster
    brain_region_spike_times = sort_spikes_three_d(s, anatData, sessionName, 0.005);
    
    %valid_region_names = cell(1, numel(region_names));
    region_names = unique(anatData.borders.acronym);
    
    % Ensure listed regions are present
    for i = 1:numel(region_names)
        valid_region_names{i} = regexprep(region_names{i}, '[^a-zA-Z0-9]', '');
        if ~isfield(brain_region_spike_times, valid_region_names{i})
            error('One of the specified region_names was not found in the brain_region_spike_times struct.');
        end
    end
    
    total_regions = numel(region_names)
end