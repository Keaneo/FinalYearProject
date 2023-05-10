function plot_coloured_matrix(mvgcMatrix, sigMatrix, minColor, maxColor, ignoreValue, rowLabels, columnLabels, alpha)
    % Get matrix size
    [rows, cols] = size(mvgcMatrix);

    % Normalize matrix values between 0 and 1
    minValue = min(mvgcMatrix(:));
    maxValue = max(mvgcMatrix(:));
    normalizedMatrix = (mvgcMatrix - minValue) / (maxValue - minValue);

    % Create a figure and axes for the plot
    figure('Position', [100, 100, 800, 820]);
    ax = axes;

    % Create grid of colored squares
    for row = 1:rows
        for col = 1:cols
            % Check for the value to be ignored
            if mvgcMatrix(row, col) == ignoreValue || row == col
                % Create a grey square
                rectangle(ax, 'Position', [col, rows - row + 1, 1, 1], ...
                             'FaceColor', [0.5 0.5 0.5], ...
                             'EdgeColor', 'none');
                
%             elseif sigMatrix(row, col)
%                 rectangle(ax, 'Position', [col, rows - row + 1, 1, 1], ...
%                             'FaceColor', [0 1 0], ...
%                             'EdgeColor', 'none');
%                 text(ax, col+0.5, rows-rows+0.5, num2str(sigMatrix(row, col)));
            else
                % Interpolate between minColor and maxColor
                color = minColor + normalizedMatrix(row, col) * (maxColor - minColor);
                % Create colored square
                rectangle(ax, 'Position', [col, rows - row + 1, 1, 1], ...
                             'FaceColor', color, ...
                             'EdgeColor', 'none');
                text(row + 0.5, cols - (col - 1.5), 1, string(sigMatrix(col, row)),"HorizontalAlignment", 'center','VerticalAlignment', 'middle')
            end
        end
    end

    % Set axes properties for the grid
    axis(ax, [1, cols + 1, 1, rows + 1]);
    ax.YDir = 'normal';
    % Add x-axis labels
    for col = 1:cols
        text(col + 0.5, 0.8, columnLabels{col}, 'HorizontalAlignment', 'center', ...
             'VerticalAlignment', 'top');
    end

    xlab = xlabel('To');
    xlab.Position(2) = xlab.Position(2) - 0.2;  

    % Add y-axis labels
    for row = 1:rows
        text(0.9, row + 0.5, rowLabels{row}, 'HorizontalAlignment', 'right', ...
             'VerticalAlignment', 'middle');
    end

    ylab = ylabel('From');
    ylab.Position(1) = ylab.Position(1) - 0.2;

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
    if max(mvgcMatrix(:)) ~= 0
        caxis([minValue, maxValue]);
        ylabel(c, 'Value');
    end
end
