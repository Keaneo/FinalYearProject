spikesMat = load(uigetfile('*.mat', 'Pick a processed TimeMatrix file...', './processed/')).timeMatrix;
%vv=spikesMat(1,1:100); %Create a new vector for one neuron to check
%plot(spikesMat(1, :));
% timebin=0.005; % In seconds
% for i=1:length(vv)


figure
for i  = 1:size(spikesMat,1)
    numSpikes = size(spikesMat,2) - sum(isnan(spikesMat(i,:)));
    plot(i, numSpikes, '*')
    hold on;
end
