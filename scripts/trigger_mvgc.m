function trigger_mvgc(rootDir, nProbe, region_names, start_time, end_time, bin_size, sessionIndx)

    %Load Session from Steinmetz dataset
    [s, sessionName] = load_session(rootDir, sessionIndx);
    nProbe = 1;
    anatData = prepare_anat_data(s, nProbe);
    
    % Sort the data into region by cluster
    brain_region_spike_times = sort_spikes(s, anatData, sessionName);
    region_names = unique(anatData.borders.acronym);
    firing_rates = avg_across_regions_no_outcome(brain_region_spike_times, region_names, start_time, end_time, bin_size);

    p_max = 10;
    alpha = 0.05;
    nperms = 500;
    sessionIndx
    [pvalues, Ftest, region_names] = mvgc_analysis(firing_rates, p_max, alpha, nperms)
    %plot_coloured_matrix(pvalues, [1, 0, 0], [0, 0, 1], 0, region_names, region_names);
    save(strcat('processed/pvalues/pval', sessionName ,'.mat'), "pvalues");
end