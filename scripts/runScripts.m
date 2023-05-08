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
    %sort_spikes_three_d(s, anatData, sessionName, bin_size);

    % Second last param is "outcome", 1 for correct, 0 for incorrect
    % Last param is "lock", set to 'RESPONSE' or 'STIM'
    filename = strcat('processed/spike_times_three_d', sessionName, 'STIM', 'INCORRECT',  '.mat');
    sort_three_d_outcomes(s, anatData, sessionName, bin_size, 0, 'STIM');

    % Perform MVGC
    trigger_mvgc(rootDir, indx, filename);
end
toc % Display time taken