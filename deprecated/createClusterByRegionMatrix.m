%%Load the timeMatrix that was created from the splitByLocation.m script.
%%This is  a matrix of spike timing organised by cluster number.

function createClusterByRegionMatrix()
    [fileName, path] = uigetfile('*.mat');
    filePath = fullfile(path,fileName);
    spikesMat = load(filePath).timeMatrix;
    
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

            fileName = regexprep(fileName,'splitByCluster','');
            if fileName == sessionNames{indx}
                %Insert code here, correct files picked - automatic comes
                %later
                brainRegions = s.channels.brainLocation;
                sites = s.channels.site;
                clusters = s.clusters;
                size(clusters)
                size(brainRegions)
            end
           
            

        end
    end
end