% INPUTS:
% time_series_data: A struct containing the time series data, with each field being a time series vector
% p_max: Maximum model order to consider for VAR model selection
% alpha: Significance level for the permutation test (e.g., 0.05)
% nperms: Number of permutations for the significance testing

function [F, Ftest, pvalues] = mvgc_analysis(time_series_data, p_max, alpha, nperms)

    % Convert struct to a 2D matrix
    time_series_names = fieldnames(time_series_data);
    n = numel(time_series_names);
    t = length(time_series_data.(time_series_names{1}));
    X = zeros(n, t);
    
    for i = 1:n
        X(i, :) = time_series_data.(time_series_names{i});
    end

    % Detrend and normalize data
    X_detrended = detrend(X', 'constant')';
    X_normalized = normalize(X_detrended', 'scale')';

    % Choose model order
    [~, AIC, BIC] = tsdata_to_infocrit(X_normalized, p_max);
    [minAIC, p_AIC] = min(AIC);
    [minBIC, p_BIC] = min(BIC);

    % Set model order, either AIC or BIC
    p = p_AIC;


    % Estimate VAR model
    [A, SIG] = tsdata_to_var(X_normalized, p);

    % Test for Granger causality
    F = var_to_pwcgc(A, SIG);

    % Significance testing
    bsize = []; % Use default (model order)
    FP = permtest_tsdata_to_pwcgc(X_normalized, p, bsize, nperms);

    % Get P-Values
    pvalues = zeros(n, n);
    for i = 1:n
        for j = 1:n
            if i ~= j
                pvalues(i, j) = sum(FP(:, i, j) >= F(i, j)) / nperms;
            end
        end
    end


    % Create a binary matrix indicating significant relationships
    Ftest = pvalues < alpha;
end
