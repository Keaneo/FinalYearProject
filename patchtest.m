% Define the x-coordinates of the lines
x = [1 1; 2 2;]; % 1000 pairs of (1,1), (2,2), ..., (1000,1000)

yourMatrix = rand(0, 500);

% Find the maximum and minimum values of yourMatrix
yMax = max(yourMatrix);
yMin = min(yourMatrix);

% Define the start and end points for each line
y = [yMin yMin; yMax yMax]; % 1000 pairs of (yMin, yMin), (yMax, yMax)

% Plot the lines using the patch function
figure
h = patch(x, y, 'b');
set(h, 'EdgeColor', 'none'); % remove the border around each patch

plot(yourMatrix)