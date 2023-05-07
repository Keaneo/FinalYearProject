function three_d_sorted = sort_spikes_three_d(s, anatData, session_name, bin_size)
    % Sorts spikes by brain region and averages into a 3d matrix for mvgc
    unique_brain_regions = unique(anatData.borders.acronym);

    % Remove invaliid characters from region names
    for i = 1:numel(unique_brain_regions)
        unique_brain_regions{i} = regexprep(unique_brain_regions{i}, '[^a-zA-Z0-9]', '');
    end

    % Setup filenames
    split_region_file = strcat('processed/spike_times_by_region', session_name, '.mat');
    filename = strcat('processed/spike_times_three_d', session_name, 'RESPONSE.mat');

    % Get the stimulus and response times from the session
    stimOn = s.trials.visualStim_times;
    response = s.trials.response_times;

    % Check if the spikes are already sorted
    if exist(filename, 'file') == 2
        fprintf('Spikes already sorted by region\n');
        load(filename);
    else
        fprintf('Spikes not sorted, sorting...\n');

        % Check if the spikes are already split by cluster
        if exist(split_region_file, 'file') == 2
            brain_region_spike_times = load(split_region_file).brain_region_spike_times;
        else
            brain_region_spike_times = sort_spikes(s, anatData, session_name);
        end

        % Init empty cell array of (region count) X (2) X (trial count)
        data_cell = cell(numel(unique_brain_regions), 2, numel(stimOn));
        
        tic % For measuring time
        % Loop each trial
        for trial_idx = 1:numel(stimOn)
            % Loop each region
            for region_idx = 1:numel(unique_brain_regions)
                % Insert region names to matrix
                data_cell{region_idx, 1, trial_idx} = unique_brain_regions{region_idx};

                % Get neurons of current region from sorted spikes
                clusters = brain_region_spike_times.(unique_brain_regions{region_idx});

                % Bin spikes into 5ms bins and average across all clusters
                % (stim-locked or response-locked, uncomment one line)
                spike_range = ((response(trial_idx) + 0.35) - (response(trial_idx) - 0.05));
                %spike_range = (stimOn(trial_idx) + 0.4 - stimOn(trial_idx));

                % Setup empty matrix for storing bins
                all_cluster_counts = zeros(numel(fieldnames(clusters)), ceil(spike_range / bin_size));

                % Get cluster ids for this region
                cluster_fieldnames = fieldnames(clusters);
                
                % Loop the clusters & sort them into bins
                for cluster_idx = 1:numel(fieldnames(clusters))
                    num_bins = ceil(spike_range / bin_size);
                    cluster_fields = fieldnames(clusters.(cluster_fieldnames{cluster_idx}));
                    counts = histcounts(clusters.(cluster_fieldnames{cluster_idx}).(cluster_fields{2}), num_bins);
                    all_cluster_counts(cluster_idx, :) = counts;
                end

                % Average across regions & divide by bin size to get rates
                avg_spike_counts = mean(all_cluster_counts, 1);
                region_firing_rates = avg_spike_counts / (bin_size);
                data_cell{region_idx, 2, trial_idx} = region_firing_rates;
            end
        end
        % Save with an appropriate variable name
        three_d_sorted = data_cell;
        save(filename, "three_d_sorted");

        fprintf('Spikes Sorted!\n');
        toc % Display time taken
    end
end
