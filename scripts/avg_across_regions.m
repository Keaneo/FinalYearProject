function firing_rates = avg_across_regions(brain_region_spike_times, region_names, start_time, end_time, bin_size)
    valid_region_names = cell(1, numel(region_names));

    for i = 1:numel(region_names)
        valid_region_names{i} = regexprep(region_names{i}, '[^a-zA-Z0-9]', '');
        if ~isfield(brain_region_spike_times, valid_region_names{i})
            error('One of the specified region_names was not found in the brain_region_spike_times struct.');
        end
    end

    firing_rates = struct();

    for r = 1:numel(valid_region_names)
        region = brain_region_spike_times.(valid_region_names{r});
        field_names = fieldnames(region);

        % Initialize a matrix to store binned spike counts for each cluster
        num_bins = ceil((end_time - start_time) / bin_size);
        all_spike_counts_correct = zeros(numel(field_names), num_bins);
        all_spike_counts_incorrect = zeros(numel(field_names), num_bins);

        for k = 1:numel(field_names)
            cluster_struct = region.(field_names{k});
            cluster_field_names = fieldnames(cluster_struct);
            cluster_name = cluster_field_names{2}
            cluster_vector = cluster_struct.(cluster_name);
            cluster_vector_correct = cluster_vector.correct;
            cluster_vector_incorrect = cluster_vector.incorrect;
            % Filter spikes based on the time range
            cluster_vector_correct = cluster_vector_correct(cluster_vector_correct >= start_time & cluster_vector_correct <= end_time);
            cluster_vector_incorrect = cluster_vector_incorrect(cluster_vector_incorrect >= start_time & cluster_vector_incorrect <= end_time);

            % Divide spike times into bins and count the number of spikes per bin
            bin_edges = start_time:bin_size:end_time;
            spike_counts_correct = histcounts(cluster_vector_correct, bin_edges);
            spike_counts_incorrect = histcounts(cluster_vector_incorrect, bin_edges);
            % Store the binned spike counts for the current cluster
            all_spike_counts_correct(k, :) = spike_counts_correct;
            all_spike_counts_incorrect(k, :) = spike_counts_incorrect;
        end

        % Calculate the average spike count across all clusters and divide by the bin size (in seconds) to get the firing rate
        avg_spike_counts_correct = mean(all_spike_counts_correct, 1);
        avg_spike_counts_incorrect = mean(all_spike_counts_incorrect, 1);
        region_firing_rates_correct = avg_spike_counts_correct / (bin_size);
        region_firing_rates_incorrect = avg_spike_counts_incorrect / (bin_size);
        
        firing_rates.(valid_region_names{r}).correct = region_firing_rates_correct;
        firing_rates.(valid_region_names{r}).incorrect = region_firing_rates_incorrect;
    end
end
