%%File to split session spike timing into matrix according to cluster
%%number - saved in files in the 'processed' folder with session name in
%%the file.

function splitByLocation()
%rootDir = uigetdir(pwd, 'Select folder containing the downloaded sessions');
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
            
            spikeTimes = s.spikes.times;
            spikeClusters = s.spikes.clusters;

            % Convert cluster numbers to valid subscripts using sub2ind
            subscripts = sub2ind([max(spikeClusters)+1 1], spikeClusters+1, ones(size(spikeClusters)));

            %Group spike timing by cluster number
            timeByCluster = accumarray(subscripts, spikeTimes, [], @(x) {x.'});

            % Get longest vector (to fill Matrix with NaN values)
            maxGroupSize = max(cellfun(@numel, timeByCluster));

            % Pad each group with NaN values so they all have the same size
            timeByCluster = cellfun(@(x) [x(:); NaN(maxGroupSize-numel(x),1)], timeByCluster, 'UniformOutput', false);
            
            %Transpose vector matrix
            timeByCluster = timeByCluster.';
            % Convert the grouped time values to a matrix & transpose back
            % (Preserves row by column access)
            timeMatrix = horzcat(timeByCluster{:}).';
            sessionNames{indx}
            % Save matrix to file
            save(strcat('processed/splitByCluster', sessionNames{indx} ,'.mat'), "timeMatrix");

        end
    end

end