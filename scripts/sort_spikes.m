function brain_region_spike_times = sort_spikes(s, anatData, session_name)
    spike_times = s.spikes.times;
    spike_clusters = s.spikes.clusters;
    unique_clusters = unique(spike_clusters);
    unique_brain_regions = unique(anatData.borders.acronym);
    filename = strcat('processed/spike_times_by_region', session_name ,'.mat');
   

    if exist(filename, 'file') == 2
        fprintf('Spikes already sorted by region\n');
        load(filename);
    else
        fprintf('Spikes not sorted, sorting...\n');
        region_spike_data_cell = cell(numel(unique_brain_regions), 1);
        % Parallelize
        if isempty(gcp('nocreate'))
            parpool;
        end
        tic
        parfor region_idx = 1:numel(unique_brain_regions)
            region = unique_brain_regions{region_idx}
            region_spike_data = struct();
            
            for cluster_idx = 1:numel(unique_clusters)
                cluster_id = unique_clusters(cluster_idx);
                channel_idx = s.clusters.peakChannel(cluster_id+1);
                channel_coord = s.channels.sitePositions(channel_idx, :);
                cluster_brain_region_idx = anatData.borders.lowerBorder <= channel_coord(2) & anatData.borders.upperBorder > channel_coord(2);
                cluster_brain_region = anatData.borders.acronym{cluster_brain_region_idx};
        
                if strcmp(region, cluster_brain_region)
                    cluster_spike_times = spike_times(spike_clusters == cluster_id);
                    cluster_data = struct('cluster_id', cluster_id, 'spike_times', cluster_spike_times);
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
        save(strcat('processed/spike_times_by_region', session_name ,'.mat'), "brain_region_spike_times");
        
        fprintf('Spikes Sorted!\n');
        toc
    end
end

