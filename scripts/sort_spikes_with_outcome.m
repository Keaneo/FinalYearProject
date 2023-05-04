function brain_region_spike_times = sort_spikes_with_outcome(s, anatData, session_name)
    spike_times = s.spikes.times;
    spike_clusters = s.spikes.clusters;
    unique_clusters = unique(spike_clusters);
    unique_brain_regions = unique(anatData.borders.acronym);
    filename = strcat('processed/spike_times_by_region_with_outcomes', session_name ,'.mat');
    
    contLeft = s.trials.visualStim_contrastLeft;
    contRight = s.trials.visualStim_contrastRight;
    stimOn = s.trials.visualStim_times;
    outcomes = s.trials.response_choice;
    response = s.trials.response_times;
    choices = zeros(length(stimOn), 1);
    for i = 1:length(stimOn)
        if contLeft(i) > contRight(i)
            % correct right
            choices(i) = (outcomes(i) == 1);
        elseif contLeft(i) < contRight(i)
            % correct left
            choices(i) = (outcomes(i) == -1);
        elseif contLeft(i) == contRight(i)
            % correct no-go
            choices(i) = (outcomes(i) == 0);
        end
    end

   if exist(filename, 'file') == 2
        fprintf('Spikes already sorted by region\n');
        load(filename);
    else
        fprintf('Spikes not sorted, sorting...\n');
        region_spike_data_cell = cell(numel(unique_brain_regions), 1);
        tic % for getting time elapsed
        parfor region_idx = 1:numel(unique_brain_regions)
            region = unique_brain_regions{region_idx}
            region_spike_data = struct();
            
            for cluster_idx = 1:numel(unique_clusters)
                cluster_id = unique_clusters(cluster_idx);
                channel_idx = s.clusters.peakChannel(cluster_id+1);
                channel_coord = s.channels.sitePositions(channel_idx, :);
                cluster_brain_region_idx = anatData.borders.lowerBorder <= channel_coord(2) & anatData.borders.upperBorder >= channel_coord(2);
                cluster_brain_region = anatData.borders.acronym{cluster_brain_region_idx};

                % Get the outcomes for each trial
                % Iterate the trials
                % Find the spikes within the times of each trial
                % Save them in their correspoding outcome label (per
                % cluster or per outcome basis???)

                if strcmp(region, cluster_brain_region)
                    cluster_spike_times = spike_times(spike_clusters == cluster_id);
                    correct_spikes = [];
                    incorrect_spikes = [];
                    for trial_idx = 1:numel(choices)
                        % Stim Locked
                        trial_spikes = cluster_spike_times(cluster_spike_times >= stimOn(trial_idx) & cluster_spike_times <= (stimOn(trial_idx) + 0.4));
                        % Response Locked
                        %trial_spikes = cluster_spike_times(cluster_spike_times >= (response(trial_idx) - 0.38) & cluster_spike_times <= (response(trial_idx) + 0.02));
                        if choices(trial_idx)
                            "Correct trial!";
                            correct_spikes = vertcat(correct_spikes, trial_spikes);
                        else
                            "Incorrect trial!";
                            incorrect_spikes = vertcat(incorrect_spikes, trial_spikes);
                        end
                    end
                    cluster_data = struct('cluster_id', cluster_id, 'outcomes', struct('correct', correct_spikes, 'incorrect', incorrect_spikes));
                    region_spike_data.(['cluster_' num2str(cluster_id)]) = cluster_data;
                end
            end
        
            region_spike_data_cell{region_idx} = region_spike_data;
        end
        valid_region_names = [];
        for i = 1:numel(unique_brain_regions)
            valid_region_names = [valid_region_names, regexprep(unique_brain_regions(i), '[^a-zA-Z0-9]', '')];
        end
        brain_region_spike_times = cell2struct(region_spike_data_cell, valid_region_names, 1);
        save(strcat('processed/spike_times_by_region_with_outcomes', session_name ,'.mat'), "brain_region_spike_times");
        
        fprintf('Spikes Sorted!\n');
        toc % print time elapsed
    end
end
