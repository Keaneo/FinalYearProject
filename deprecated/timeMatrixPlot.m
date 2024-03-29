spikesMat = load(uigetfile('*.mat', 'Pick a processed TimeMatrix file...', './processed/')).timeMatrix;

%List of cluster numbers we want to plot firing rates for.
%clusterNums = [472, 563]; %282 is a longer vector for comparison
%clusterNums = 1:10;
%clusterNums = 465:480;
clusterNums = 472;
binSize = 0.020; %5ms

startCol = 1;
endCol = 200;
spikesMat = spikesMat(:, startCol:endCol);
numColumns = getNumBins(spikesMat, clusterNums, binSize);

rates = zeros(length(clusterNums), numColumns);

figure
%Iterate clusterNums and get firing rates for each
for i = 1:length(clusterNums)
    clusterNum = clusterNums(i);
    counts = smoothFiringRates(getFiringRate(spikesMat, clusterNum, binSize));
    %counts = getFiringRate(spikesMat, clusterNum, binSize);
    counts(1, end:numColumns) = 0;
    rates(i,:) = counts;
    plot(counts);
    hold on;
end



% Plot!
%bar(BIN_SIZES(1:200), counts(1:200));

%bar(BIN_SIZES2(1:end-1), counts2, 'r');
xlabel('Time (s)');
ylabel('Counts');
title('Number of time values in bins of 5ms');
hold off;



% Load decisions
figure(2);

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

        for i = 1:size(s.clusters.depths)
            train = spikesMat(i, :);
            plot(train)
            hold on;
        end
    end
end

%Function to get firing rate
%   spikesMat: needs the spiking matrix (matrix of spike times by cluster)
%   clusterNum: is the cluster number to get the firing rate of
%   binSize: is the size of the bins to split the data into (in seconds! use 0.05 for 5ms)
function counts = getFiringRate(spikesMat, clusterNum, binSize)
    %Define sizes of bin - binSize from start of time until end of cluster
    BIN_SIZES = 0:binSize:max(spikesMat(clusterNum, :));

    %Split vector into bins
    counts = histcounts(spikesMat(clusterNum, :), BIN_SIZES);
    counts = counts ./ binSize; % convert counts to rates
end

function highestCount = getNumBins(spikesMat, clusterNums, binSize)
    highestCount = 0;

    for i = 1:length(clusterNums)
        clusterNum = clusterNums(i);
        %Define sizes of bin - binSize from start of time until end of cluster
        BIN_SIZES = 0:binSize:max(spikesMat(clusterNum, :));
        if length(BIN_SIZES) > highestCount
            highestCount = length(BIN_SIZES);
        end
    end
end

function smoothed = smoothFiringRates(rates)
    sigma = 1; % standard deviation of the Gaussian distribution
    n = 5*sigma; % number of filter coefficients
    x = linspace(-n/2, n/2, n);
    kernel = exp(-x.^2/(2*sigma^2));
    kernel(x<0) = 0;
    kernel = kernel / sum(kernel); % normalize the kernel

    smoothed = filter(kernel, 1, rates);
end