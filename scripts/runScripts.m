% SETUP AND VARIABLE DEFAULTS 
%================================================
% Directory to find Steinmetz data
rootDir = './allData'; 

% Size (in seconds) of bin to get firing rate for
bin_size = 0.005;

% Get available sessions
d = dir(fullfile(rootDir, '*')); 
d = d([d.isdir]); 
sessionNames = {d.name};

tic
% Parallel Loop to process multiple sessions at once
parfor indx = 1:numel(sessionNames) - 2 % minus two to ignore the . and ..
    % Load current session
    [s, sessionName] = load_session(rootDir, indx);
    anatData = prepare_anat_data(s, 1);

    % Sort spikes for MVGC
    sort_spikes_three_d(s, anatData, sessionName, bin_size);

    % Perform MVGC
    trigger_mvgc(rootDir, indx);
end
toc % Display time taken