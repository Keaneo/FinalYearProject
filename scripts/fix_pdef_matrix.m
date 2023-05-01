function [X_fixed, p_max_fixed] = fix_pdef_matrix(X, p_max, reg_factor)
    % Function to fix non-positive definite matrices
    
    % Inputs:
    % X: The input matrix (time series dataset)
    % p_max: Maximum model order
    % reg_factor: Regularization factor for adding to the diagonal elements
    
    % Outputs:
    % X_fixed: Fixed input matrix
    % p_max_fixed: Fixed maximum model order
    
    X_fixed = X;
    p_max_fixed = p_max;
    
    % Check if the matrix is positive definite
    [~, p] = chol(X_fixed * X_fixed');
    if p == 0
        disp('Matrix is already positive definite.');
        return;
    end
    
    % Step 1: Remove collinearity
    [~, score, ~] = pca(X_fixed');
    X_fixed = score';
    [~, p] = chol(X_fixed * X_fixed');
    if p == 0
        disp('Matrix is now positive definite after removing collinearity.');
        return;
    end
    
    % Step 2: Regularization (jittering)
    X_fixed = X_fixed + reg_factor * eye(size(X_fixed, 1));
    [~, p] = chol(X_fixed * X_fixed');
    if p == 0
        disp('Matrix is now positive definite after regularization.');
        return;
    end
    
    % Step 3: Adjust the model order
    for i = p_max_fixed - 1:-1:1
        [~, ~, moaic, ~] = tsdata_to_infocrit(X_fixed, i);
        [~, p] = chol(moaic * moaic');
        if p == 0
            p_max_fixed = i;
            disp(['Matrix is now positive definite after adjusting the model order to ', num2str(p_max_fixed), '.']);
            return;
        end
    end
    
    error('Matrix cannot be fixed to become positive definite.');
end
