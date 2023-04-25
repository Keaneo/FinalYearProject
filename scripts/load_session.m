function [s, sessionName] = load_session(rootDir, indx)
    if ~isempty(rootDir)
        d = dir(fullfile(rootDir, '*')); 
        d = d([d.isdir]); 
        sessionNames = {d.name}; 
        sessionNames = sessionNames(~strcmp(sessionNames, '.') & ~strcmp(sessionNames,'..')); 
        if nargin < 2 || isempty(indx)
            indx = listdlg('ListString',sessionNames, 'Name', 'Select a session');
        end

        if ~isempty(indx)
            s = loadSession(fullfile(rootDir, sessionNames{indx}));
            sessionName = sessionNames{indx};
        end
    end
end
