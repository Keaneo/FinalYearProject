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
        choices(i)
    end

    if exist(filename, 'file') == 2
        fprintf('Spikes already sorted\n');
        load(filename);
    else
        fprintf('Spikes not sorted, sorting...\n');
        brain_region_spike_times = struct();
        for region_idx = 1:numel(unique_brain_regions)
            region = unique_brain_regions{region_idx};
            region_spike_data = struct('correct', struct(), 'incorrect', struct());
            
            for cluster_idx = 1:numel(unique_clusters)
                cluster_id = unique_clusters(cluster_idx);
                channel_idx = s.clusters.peakChannel(cluster_id+1);
                channel_coord = s.channels.sitePositions(channel_idx, :);
                cluster_brain_region_idx = anatData.borders.lowerBorder <= channel_coord(2) & anatData.borders.upperBorder > channel_coord(2);
                cluster_brain_region = anatData.borders.acronym{cluster_brain_region_idx};
        
                if strcmp(region, cluster_brain_region)
                    for trial_idx = 1:length(stimOn)
                        trial_start = stimOn(trial_idx);
                        cluster_spike_times = spike_times(spike_clusters == cluster_id);
                        spike_indices = cluster_spike_times >= trial_start & cluster_spike_times < trial_start + 0.4;
                        trial_spike_times = cluster_spike_times(spike_indices);
                        
                        if choices(trial_idx) == true
                            outcome = 'correct';
                        else
                            outcome = 'incorrect';
                        end
                        field_name = ['cluster_' num2str(cluster_id)];
                        if ~isfield(region_spike_data.(outcome), field_name)
                            region_spike_data.(outcome).(field_name) = struct('cluster_id', cluster_id, 'spike_times', {cell(numel(trial_spike_times), 1)}); 
                            region_spike_data.(outcome).(field_name).spike_times{1} = trial_spike_times;
                        else
                            region_spike_data.(outcome).(['cluster_' num2str(cluster_id)]).spike_times{end+1} = trial_spike_times;
                        end
                    end
                end
            end
        
            valid_field_name = regexprep(region, '[^a-zA-Z0-9]', '');
            brain_region_spike_times.(valid_field_name) = region_spike_data;
            save(filename, "brain_region_spike_times");
        end
        fprintf('Spikes Sorted!');
    end
end
