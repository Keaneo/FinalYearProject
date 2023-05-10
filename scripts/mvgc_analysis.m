function [pvalues, F, time_series_names] = mvgc_analysis(time_series_data, p_max, alpha, nperms)
    % INPUTS:
    % time_series_data: A struct containing the time series data, with each field being a time series vector
    % p_max: Maximum model order to consider for VAR model selection
    % alpha: Significance level for the permutation test (e.g., 0.05)
    % nperms: Number of permutations for the significance testing
    time_series_data.three_d_sorted{1, 1, 1};

    % Find rows with NaN elements & remove them     
    fields = time_series_data.three_d_sorted(:, 1, 1);
    hasNaN = false(1, numel(fields));
    for i = 1:numel(fields)
        hasNaN(i) = any(isnan(time_series_data.three_d_sorted{i, 2, 1}));
        if hasNaN(i) || strcmp(fields{i}, 'root')
            % Remove every row in the matrix at that index to preserve shape
            time_series_data.three_d_sorted(i, :, :) = [];
            break;            
        end
    end

    % Convert struct to a 2D matrix
    time_series_names = time_series_data.three_d_sorted(:, 1, 1);
    n = size(time_series_data.three_d_sorted, 1);
    m = size(time_series_data.three_d_sorted{1, 2, 1}, 2) - 1; %Division in the sorting process left 1 extra data point, so we remove it
    N = size(time_series_data.three_d_sorted, 3);
    X = zeros(n, m, N);
    
    for k = 1:N
        for i = 1:n
            if size(time_series_data.three_d_sorted{i, 2, k},2) > m
                for j = 1:(size(time_series_data.three_d_sorted{i, 2, k},2) - m)
                    time_series_data.three_d_sorted{i, 2, k}(end) = [];
                end
            end
            X(i, :, k) = normalize(detrend(time_series_data.three_d_sorted{i, 2, k}, 'constant'), 'scale');
            
        end
    end

    X_normalized = X;

%     % Detrend and normalize data
%     X_detrended = detrend(X', 'constant')';
%     X_normalized = normalize(X_detrended', 'scale')';

%     [X_normalized, p_max] = fix_pdef_matrix(X, p_max, 1e-6);

    % Choose model order
    [AIC, BIC, moaic, mobic] = tsdata_to_infocrit(X_normalized, p_max);
    [minAIC, p_AIC] = min(AIC);
    [minBIC, p_BIC] = min(BIC);

    % You can choose the model order based on either AIC or BIC
    p = p_AIC; % Or use p_BIC, depending on your choice
    p_opt = moaic;

    % Estimate VAR model
    [A, SIG] = tsdata_to_var(X_normalized, p_opt, 'LWR');

     % Test for Granger causality
    [F, pvalues] = var_to_pwcgc(A, SIG, X_normalized, 'LWR');

    % Significance testing
    %bsize = []; % Use default (model order)
    %FP = permtest_tsdata_to_pwcgc(X_normalized, p, bsize, nperms);

%     pvalues = zeros(n, n);
%     for i = 1:n
%         for j = 1:n
%             if i ~= j
%                 pvalues(i, j) = sum(FP(:, i, j) >= F(i, j)) / nperms;
%             end
%         end
%     end
    
end