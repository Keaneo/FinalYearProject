function trigger_mvgc(rootDir, sessionIndx, filename, graphSave)

    %Load Session from Steinmetz dataset
    [s, sessionName] = load_session(rootDir, sessionIndx);

    % Load the sorted data
    if nargin < 3
        filename = strcat('processed/spike_times_three_d', sessionName, 'RESPONSE.mat');
    end
    three_d_sorted = load(filename, "three_d_sorted");

    % Setup parameters for F-test
    p_max = 10;
    alpha = 0.05;
    nperms = 500;

    if(size(three_d_sorted.three_d_sorted, 3) < 1)
        return;
    end

    % Run MVGC
    [pvalues, F, region_names] = mvgc_analysis(three_d_sorted, p_max, alpha, nperms);

    % Check the returned matrix is valid
    if isnan(pvalues)
        return
    end

    % Create a matrix of significant relationships
%     significant_values = double((pvalues < alpha) & (pvalues > 0));

    % Plot the results
    plot_coloured_matrix(F, pvalues, [1, 0, 0], [0, 0, 1], 0, region_names, flip(region_names), alpha);

    % Save an image of the graph and the GC matrix
    %save(strcat('processed/pvalues/pval', sessionName ,'.mat'), "F");  

    choice = graphSave{1};
    lock = graphSave{2};
    correct = graphSave{3};
    folder = graphSave{4};

    if choice == 1
        choice_name = "_left";
    elseif choice == 0
        choice_name = "_nogo";
    else
        choice_name = "_right";
    end
    saveas(gcf, strcat('graphs/', folder, '/', sessionName, lock, choice_name, correct,'.png'));

    % Export for Excel
    %writematrix(significant_values, strcat('processed/excel/', sessionName ,'sigValuesRESPONSE.xls'))
    
end