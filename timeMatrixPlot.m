spikesMat = load(uigetfile('*.mat')).timeMatrix;

%Ask user for cluster number
clusterNum = inputdlg('', '', [1 35], {'0'});
%472 is good
ROW = str2num(clusterNum{1}); %#ok<ST2NM> 

%Define sizes of bin - 5ms from start of time until end of cluster
BIN_SIZES = 0:0.05:max(spikesMat(ROW,:));

%Split vector into bins
counts = histcounts(spikesMat(ROW,:), BIN_SIZES);
%counts = counts ./ 0.05;

%=============2ND SPIKE TRAIN==========
%Ask user for cluster number
clusterNum2 = inputdlg('Please enter a cluster number...', 'Cluster Number', [1 35], {'0'});
%472 is good
ROW2 = str2num(clusterNum2{1}); %#ok<ST2NM> 

%Define sizes of bin - 5ms from start of time until end of cluster
BIN_SIZES2 = 0:0.05:max(spikesMat(ROW2,:));

%Split vector into bins
counts2 = histcounts(spikesMat(ROW2,:), BIN_SIZES2);

% Plot!
figure
%bar(BIN_SIZES(1:200), counts(1:200)); 
plot(counts)
hold on;
%bar(BIN_SIZES2(1:end-1), counts2, 'r');
xlabel('Time (s)');
ylabel('Counts');
title('Number of time values in bins of 5ms');

%Print highest bin count
max(counts)