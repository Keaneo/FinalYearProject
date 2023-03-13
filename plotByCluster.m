spikesMat = load(uigetfile('*.mat', 'Pick a processed TimeMatrix file...', './processed/')).timeMatrix;

rootDir = './allData';
if ~isempty(rootDir)
    d = dir(fullfile(rootDir, '*')); 
    d = d([d.isdir]); 
    sessionNames = {d.name}; 
    sessionNames = sessionNames(~strcmp(sessionNames, '.') & ~strcmp(sessionNames,'..')); 
    indx = listdlg('ListString',sessionNames, 'Name', 'Select a session');

    if ~isempty(indx)
        
        % load session 
        s = loadSession(fullfile(rootDir, sessionNames{indx}));
    end
end

%Pick the clusters from spikesMat
spikesMat = spikesMat(1:10, :);

figure
% USEFUL - Plot the count of spikes for each cluster
% Good for looking at active vs inactive neurons
%
% for i  = 1:size(spikesMat,1)
%     numSpikes = size(spikesMat,2) - sum(isnan(spikesMat(i,:)));
%     plot(i, numSpikes, '*')
%     hold on;
% end

%Turn on grid and get the max time value from the matrix
grid on;
maxVal = max(spikesMat, [], 'all')

% Set graph limits - X is highest time, Y is number of clusters (1-indexed)
xlim([0 maxVal]);
ylim([1 size(spikesMat, 1) + 1]);
ylabel("Cluster Number");
xlabel("Time (s)");

% Loop the clusters we picked
for j = 1:size(spikesMat, 1)
    %Find the number of spikes in that cluster & loop them
    numSpikes = size(spikesMat,2) - sum(isnan(spikesMat(j,:)))
    for i = 1:numSpikes
        %Plot a vertical line for the spike time
        line([spikesMat(j, i), spikesMat(j, i)], [j j+1]);
        hold on;
    end
end

contLeft = s.trials.visualStim_contrastLeft;
contRight = s.trials.visualStim_contrastRight;
outcomes = s.trials.response_choice;
intervals = s.trials.intervals;
stimOn = s.trials.visualStim_times;
CORRECT_COLOUR = [0.1 1 0.1];
WRONG_COLOUR = [1 0.1 0.1];

for i = 1:size(stimOn, 1)
    line([stimOn(i), stimOn(i)], [1 size(spikesMat, 1) + 1], 'color', 'r');
end

% for i = 1:size(intervals, 1)
%     % Is the left contrast higher than the right?
%     % This would make a right turn the correct one. And etc.
%     if contLeft(i) > contRight(i)
%         correct = 1;
%     elseif contLeft(i) < contRight(i)
%         correct = -1;
%     elseif contLeft(i) == contRight(i)
%         correct = 0;
%     end
%     % If correct, paint a green square, otherwise do red.
%     % Width of a square represent the trial length.
%     if correct == outcomes(i)                    
%         patch([intervals(i,1) intervals(i,1) intervals(i,2) intervals(i,2)], [0 size(spikesMat, 1) + 1 size(spikesMat, 1) + 1 0], CORRECT_COLOUR);
%     else
%         patch([intervals(i,1) intervals(i,1) intervals(i,2) intervals(i,2)], [0 size(spikesMat, 1) + 1 size(spikesMat, 1) + 1 0], WRONG_COLOUR);
%     end
% end
