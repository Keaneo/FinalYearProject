function trigger_mvgc(rootDir, sessionIndx)

    %Load Session from Steinmetz dataset
    [s, sessionName] = load_session(rootDir, sessionIndx);

    % Load the sorted data
    filename = strcat('processed/spike_times_three_d', sessionName, 'RESPONSE.mat');
    three_d_sorted = load(filename, "three_d_sorted");

    % Setup parameters for F-test
    p_max = 10;
    alpha = 0.05;
    nperms = 500;

    % Run MVGC
    [pvalues, F, region_names] = mvgc_analysis(three_d_sorted, p_max, alpha, nperms)

    % Check the returned matrix is valid
    if isnan(pvalues)
        return
    end

    % Create a matrix of significant relationships
    significant_values = double((pvalues < alpha) & (pvalues > 0));

    % Plot the results
    plot_coloured_matrix(F, significant_values, [1, 0, 0], [0, 0, 1], 0, region_names, flip(region_names), alpha);

    % Save an image of the graph and the GC matrix
    save(strcat('processed/pvalues/pval', sessionName ,'.mat'), "F");    
    saveas(gcf, strcat('graphs/', sessionName, 'RESPONSE.png'));

    % Export for Excel
    %writematrix(significant_values, strcat('processed/excel/', sessionName ,'sigValuesRESPONSE.xls'))
    
end