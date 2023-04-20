function plot_coloured_matrix(matrix, minColor, maxColor, ignoreValue)
    % Get matrix size
    [rows, cols] = size(matrix);

    % Normalize matrix values between 0 and 1
    minValue = min(matrix(:));
    maxValue = max(matrix(:));
    normalizedMatrix = (matrix - minValue) / (maxValue - minValue);

    % Create a figure and axes for the plot
    figure;
    ax = axes;

    % Create grid of colored squares
    for row = 1:rows
        for col = 1:cols
            % Check for the value to be ignored
            if matrix(row, col) == ignoreValue
                % Create a grey square
                rectangle(ax, 'Position', [col, rows - row + 1, 1, 1], ...
                             'FaceColor', [0.5 0.5 0.5], ...
                             'EdgeColor', 'none');
            else
                % Interpolate between minColor and maxColor
                color = minColor + normalizedMatrix(row, col) * (maxColor - minColor);
                % Create colored square
                rectangle(ax, 'Position', [col, rows - row + 1, 1, 1], ...
                             'FaceColor', color, ...
                             'EdgeColor', 'none');
            end
        end
    end

    % Set axes properties for the grid
    axis(ax, [1, cols + 1, 1, rows + 1]);
    ax.YDir = 'normal';
    axis equal tight;
    box on;
    grid on;
    set(ax, 'XTick', 1.5:1:cols + 0.5, 'YTick', 1.5:1:rows + 0.5, ...
            'XTickLabel', [], 'YTickLabel', [], ...
            'XColor', 'k', 'YColor', 'k', 'GridLineStyle', '-');

    % Create a colorbar with the appropriate min and max colors
    colormap(ax, [linspace(minColor(1), maxColor(1), 256)', ...
                  linspace(minColor(2), maxColor(2), 256)', ...
                  linspace(minColor(3), maxColor(3), 256)']);
    c = colorbar;
    caxis([minValue, maxValue]);
    ylabel(c, 'Value');
end
