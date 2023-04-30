function brain_region_spike_times = sort_spikes_with_outcome(s, anatData, session_name)
    % Initialize important variables
    spike_times = s.spikes.times;
    spike_clusters = s.spikes.clusters;
    unique_clusters = unique(spike_clusters);
    unique_brain_regions = unique(anatData.borders.acronym);
    filename = strcat('processed/spike_times_by_region_with_outcomes', session_name ,'.mat');
    
    % Calculate contrast values and set up trial choices
    contLeft = s.trials.visualStim_contrastLeft;
    contRight = s.trials.visualStim_contrastRight;
    stimOn = s.trials.visualStim_times;
    outcomes = s.trials.response_choice;
    choices = zeros(length(stimOn), 1);
    for i = 1:length(stimOn)
        if contLeft(i) > contRight(i)
            choices(i) = (outcomes(i) == 1);
        elseif contLeft(i) < contRight(i)
            choices(i) = (outcomes(i) == -1);
        elseif contLeft(i) == contRight(i)
            choices(i) = (outcomes(i) == 0);
        end
    end

    % Check if spike data is already sorted by region
   if exist(filename, 'file') == 2
        fprintf('Spikes already sorted by region\n');
        load(filename);
    else
        fprintf('Spikes not sorted, sorting...\n');
        region_spike_data_cell = cell(numel(unique_brain_regions), 1);
        
        % Start timing
        tic 

        % Splitting spikes by cluster and getting outcomes for each trial
        cluster_data_cell = cell(numel(unique_clusters), 1);
        parfor cluster_idx = 1:numel(unique_clusters)
            cluster_id = unique_clusters(cluster_idx);
            cluster_spike_times = spike_times(spike_clusters == cluster_id);
            channel_idx = s.clusters.peakChannel(cluster_id+1);
            channel_coord = s.channels.sitePositions(channel_idx, :);
            cluster_brain_region_idx = anatData.borders.lowerBorder <= channel_coord(2) & anatData.borders.upperBorder >= channel_coord(2);
            cluster_brain_region = anatData.borders.acronym{cluster_brain_region_idx};
            
            correct_spikes = [];
            incorrect_spikes = [];
            for trial_idx = 1:numel(choices)
                trial_spikes = cluster_spike_times;
                if choices(trial_idx)
                    correct_spikes = vertcat(correct_spikes, trial_spikes);
                else
                    incorrect_spikes = vertcat(incorrect_spikes, trial_spikes);
                end
            end
            cluster_data = struct('cluster_id', cluster_id, 'outcomes', struct('correct', correct_spikes, 'incorrect', incorrect_spikes), 'region', cluster_brain_region);
            cluster_data_cell{cluster_idx} = cluster_data;
        end

        % Getting indices of clusters within region
        for region_idx = 1:numel(unique_brain_regions)
            region_spike_data_cell{region_idx} = cluster_data_cell(strcmp({cluster_data_cell{:}.region}, unique_brain_regions{region_idx}));
        end

        % Renaming region names to valid variable names
        valid_region_names = cellfun(@(x) regexprep(x, '[^a-zA-Z0-9]', ''), unique_brain_regions, 'UniformOutput', false);
        brain_region_spike_times = cell2struct(region_spike_data_cell, valid_region_names, 1);

        % Saving the sorted spike times
        save(strcat('./processed/spike_times_by_region_with_outcomes', session_name ,'.mat'), "brain_region_spike_times", '-v7.3');
        
        fprintf('Spikes Sorted!\n');
        toc % print time elapsed
    end
end
