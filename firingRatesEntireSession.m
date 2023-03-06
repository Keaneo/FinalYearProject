rootDir = './allData';

probeIndex = 1; % Must be 1 or higher

if ~isempty(rootDir)
    d = dir(fullfile(rootDir, '*')); 
    d = d([d.isdir]); 
    sessionNames = {d.name}; 
    sessionNames = sessionNames(~strcmp(sessionNames, '.') & ~strcmp(sessionNames,'..')); 
    indx = listdlg('ListString',sessionNames, 'Name', 'Select a session');

    if ~isempty(indx)
        
        % load session 
        s = loadSession(fullfile(rootDir, sessionNames{indx}));
        s.channels.probe
        %Get clusters & spike indices for that probe
        inclCID = find(s.clusters.probes==probeIndex-1)-1; 
        inclSpikes = ismember(s.spikes.clusters, inclCID);
        %Get spike times and clusters
        spiketimes = s.spikes.times(inclSpikes); 
        clusters = s.spikes.clusters(inclSpikes); 

        std(spiketimes)
        mean(spiketimes)

        rates = getFiringRate(spiketimes, 0.005);
        smoothed = smoothFiringRates(rates);
        plot(smoothed);

        xlabel('Time (s)');
        ylabel('Firing Rate (Hz)');

        
    end
end

function rate = getFiringRate(spiketimes, binSize)
    BIN_SIZES = 0:binSize:max(spiketimes);

    %Split vector into bins
    counts = histcounts(spiketimes, BIN_SIZES);
    %Convert to rate
    rate = counts ./ binSize;
end

function smoothed = smoothFiringRates(rates)
    sigma = 1; % standard deviation of the Gaussian distribution
    n = 5*sigma; % number of filter coefficients
    x = linspace(-n/2, n/2, n);
    kernel = exp(-x.^2/(2*sigma^2));
    kernel(x<0) = 0;
    kernel = kernel / sum(kernel); % normalize the kernel

    smoothed = conv(rates, kernel, 'same');
end