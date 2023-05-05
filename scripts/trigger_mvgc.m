function trigger_mvgc(rootDir, nProbe, region_names, start_time, end_time, bin_size, sessionIndx)

    %Load Session from Steinmetz dataset
    [s, sessionName] = load_session(rootDir, sessionIndx);
    %nProbe = 1;
    %anatData = prepare_anat_data(s, nProbe);
    
    % Sort the data into region by cluster
    %brain_region_spike_times = sort_spikes(s, anatData, sessionName);
    %region_names = unique(anatData.borders.acronym)
    %firing_rates = avg_across_regions_no_outcome(brain_region_spike_times, region_names, start_time, end_time, bin_size);
    filename = strcat('processed/spike_times_three_d', sessionName, '.mat');
    three_d_sorted = load(filename, "three_d_sorted");
    p_max = 10;
    alpha = 0.05;
    nperms = 500;
    sessionIndx
    [pvalues, F, region_names] = mvgc_analysis(three_d_sorted, p_max, alpha, nperms)
    if isnan(pvalues)
        return
    end
    % Create a matrix of significant relationships
    significant_values = double((pvalues < alpha) & (pvalues > 0));
    plot_coloured_matrix(F, significant_values, [1, 0, 0], [0, 0, 1], 0, region_names, flip(region_names), alpha);
    save(strcat('processed/pvalues/pval', sessionName ,'.mat'), "F");
    saveas(gcf, strcat('graphs/', sessionName, '.png'));
end