function three_d_sorted = sort_spikes_three_d(s, anatData, session_name, bin_size)
    % Sorts spikes by brain region and averages into a 3d matrix for mvgc
    spike_times = s.spikes.times;
    spike_clusters = s.spikes.clusters;
    unique_clusters = unique(spike_clusters);
    unique_brain_regions = unique(anatData.borders.acronym);

    for i = 1:numel(unique_brain_regions)
        unique_brain_regions{i} = regexprep(unique_brain_regions{i}, '[^a-zA-Z0-9]', '');
    end

    split_region_file = strcat('processed/spike_times_by_region', session_name, '.mat');
    filename = strcat('processed/spike_times_three_d', session_name, 'REPONSE.mat');

    stimOn = s.trials.visualStim_times;
    response = s.trials.response_times;

    if exist(filename, 'file') == 2
        fprintf('Spikes already sorted by region\n');
        load(filename);
    else
        fprintf('Spikes not sorted, sorting...\n');

        if exist(split_region_file, 'file') == 2
            brain_region_spike_times = load(split_region_file).brain_region_spike_times;
        else
            brain_region_spike_times = sort_spikes(s, anatData, session_name);
        end

%         data_cell = cell(214, 1);
%         for i = 1:214
%             data_cell{i} = cell(4, 2);
%         end
        data_cell = cell(numel(unique_brain_regions), 2, numel(stimOn));
        tic

        for trial_idx = 1:numel(stimOn)

            for region_idx = 1:numel(unique_brain_regions)
                data_cell{region_idx, 1, trial_idx} = unique_brain_regions{region_idx};
                clusters = brain_region_spike_times.(unique_brain_regions{region_idx});
                % Bin spikes into 5ms bins and average across all clusters

                spike_range = ((response(trial_idx) + 0.35) - (response(trial_idx) - 0.05));
                %spike_range = (stimOn(trial_idx) + 0.4 - stimOn(trial_idx));

                all_cluster_counts = zeros(numel(fieldnames(clusters)), ceil(spike_range / bin_size));
                cluster_fieldnames = fieldnames(clusters);
                for cluster_idx = 1:numel(fieldnames(clusters))
                    num_bins = ceil(spike_range / bin_size);
                    cluster_fields = fieldnames(clusters.(cluster_fieldnames{cluster_idx}));
                    counts = histcounts(clusters.(cluster_fieldnames{cluster_idx}).(cluster_fields{2}), num_bins);
                    all_cluster_counts(cluster_idx, :) = counts;
                end
                avg_spike_counts = mean(all_cluster_counts, 1);
                region_firing_rates = avg_spike_counts / (bin_size);
                data_cell{region_idx, 2, trial_idx} = region_firing_rates;
            end

        end

        %three_d_sorted = cell2struct(data_cell, unique_brain_regions, 1);
        three_d_sorted = data_cell;
        save(filename, "three_d_sorted");

        fprintf('Spikes Sorted!\n');
        toc
    end

end
