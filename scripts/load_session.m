function [s, sessionName] = load_session(rootDir)
    if ~isempty(rootDir)
        d = dir(fullfile(rootDir, '*')); 
        d = d([d.isdir]); 
        sessionNames = {d.name}; 
        sessionNames = sessionNames(~strcmp(sessionNames, '.') & ~strcmp(sessionNames,'..')); 
        indx = listdlg('ListString',sessionNames, 'Name', 'Select a session');

        if ~isempty(indx)
            s = loadSession(fullfile(rootDir, sessionNames{indx}));
            sessionName = sessionNames{indx};
        end
    end
end
