function plot_meta_matrix(matrixList, minColor, maxColor, ignoreValue, rowLabelList, columnLabelList)
    % Get the number of matrices
    nMatrices = numel(matrixList);
    
    % Get the size of each matrix
    matrixSizes = cellfun(@(x) size(x), matrixList, 'UniformOutput', false);
    matrixRows = cellfun(@(x) x(1), matrixSizes);
    matrixCols = cellfun(@(x) x(2), matrixSizes);

    % Find unique row and column labels across all matrices
    uniqueRowLabels = unique(cat(1, rowLabelList{:}));
    uniqueColLabels = unique(cat(1, columnLabelList{:}));

    % Create a mapping from each row and column label to an index in the final grid
    rowIndices = containers.Map(uniqueRowLabels, 1:numel(uniqueRowLabels));
    colIndices = containers.Map(uniqueColLabels, 1:numel(uniqueColLabels));

    % Create a flag indicating if a row label needs to be flipped
    flipRowLabels = false(numel(uniqueRowLabels), 1);
    for i = 1:numel(uniqueRowLabels)
        rowLabel = uniqueRowLabels{i};
        colLabels = cat(1, columnLabelList{:});
        flipRowLabels(i) = any(strcmp(rowLabel, colLabels));
    end

    % Create a figure and axes for the plot
    figure;
    ax = axes;

    % Create grid of colored squares
    for iMatrix = 1:nMatrices
        matrix = matrixList{iMatrix};
        rows = matrixRows(iMatrix);
        cols = matrixCols(iMatrix);
        rowLabels = rowLabelList{iMatrix};
        columnLabels = columnLabelList{iMatrix};

        % Normalize matrix values between 0 and 1
        minValue = min(matrix(:));
        maxValue = max(matrix(:));
        normalizedMatrix = (matrix - minValue) / (maxValue - minValue);

        % Add colored squares to the grid
        for row = 1:rows
            for col = 1:cols
                % Get the row and column labels for this square
                rowLabel = rowLabels{row};
                colLabel = columnLabels{col};

                % Get the indices for this row and column in the final grid
                rowIndex = rowIndices(rowLabel);
                colIndex = colIndices(colLabel);

                % Check if the row labels need to be flipped
                if flipRowLabels(rowIndex) && col == cols
                    % Flip the row labels for this row
                    rowLabels = rowLabels(end:-1:1);
                    % Recompute the row index for this square
                    rowIndex = rowIndices(rowLabel);
                end

                % Check for the value to be ignored
                if matrix(row, col) == ignoreValue || row == col
                    % Create a grey square
                    rectangle(ax, 'Position', [colIndex, numel(uniqueRowLabels) - rowIndex + 1, 1, 1], ...
                                 'FaceColor', [0.5 0.5 0.5], ...
                                 'EdgeColor', 'none');
                else
                    % Interpolate between minColor and maxColor
                    color = minColor + normalizedMatrix(row, col) * (maxColor - minColor);
                    % Create colored square
                    rectangle(ax, 'Position', [colIndex, numel(uniqueRowLabels) - rowIndex + 1, 1, 1], ...
                                 'FaceColor', color, ...
                                 'EdgeColor', 'none');
                end
            end
        end
    end

    % Set axes properties for the grid
    axis(ax, [1, numel(uniqueColLabels) + 1, 1, numel(uniqueRowLabels) + 1]);
    ax.YDir = 'normal';
    % Add x-axis labels
    for col = 1:numel(uniqueColLabels)
        text(col + 0.5, 0.5, uniqueColLabels{col}, 'HorizontalAlignment', 'center', ...
             'VerticalAlignment', 'top', 'Rotation', 90);
    end
    
    % Add y-axis labels
    for row = 1:numel(uniqueRowLabels)
        text(0.5, row + 0.5, uniqueRowLabels{row}, 'HorizontalAlignment', 'right', ...
             'VerticalAlignment', 'middle');
    end

    axis equal tight;
    box on;
    grid on;
    set(ax, 'XTick', [], 'YTick', [], ...
        'XColor', 'k', 'YColor', 'k', 'GridLineStyle', '-');

    % Create a colorbar with the appropriate min and max colors
    colormap(ax, [linspace(minColor(1), maxColor(1), 256)', ...
                  linspace(minColor(2), maxColor(2), 256)', ...
                  linspace(minColor(3), maxColor(3), 256)']);
    c = colorbar;
    if max(cat(1, matrixList{:})) ~= 0
        caxis([min(cat(1, matrixList{:})), max(cat(1, matrixList{:}))]);
        ylabel(c, 'Value');
    end
end
