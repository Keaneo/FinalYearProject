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

% Second last param is "outcome", 1 for correct, 0 for incorrect
% or it's "choice", 1 is left, 0 is nogo, -1 is right
% Last param is "lock", set to 'RESPONSE' or 'STIM'
% choice = -1;
% lock = 'STIM';
% correct = 'CORRECT';
% 
% folders = {
%     {-1, 'STIM', 'CORRECT', 'right_turn_right_correct_stim'};
%     {-1, 'STIM', 'INCORRECT', 'right_turn_left_correct_stim'};
%     {1, 'STIM', 'CORRECT', 'left_turn_left_correct_stim'};
%     {1, 'STIM', 'INCORRECT', 'left_turn_right_correct_stim'};
%     {-1, 'RESPONSE', 'CORRECT', 'right_turn_right_correct_response'};
%     {-1, 'RESPONSE', 'INCORRECT', 'right_turn_left_correct_response'};
%     {1, 'RESPONSE', 'CORRECT', 'left_turn_left_correct_response'};
%     {1, 'RESPONSE', 'INCORRECT', 'left_turn_right_correct_response'};
% };

folders = {
    {-1, 'STIM', 'CORRECT', 'correct_stim'};
    {-1, 'STIM', 'INCORRECT', 'incorrect_stim'};
    {1, 'RESPONSE', 'CORRECT', 'correct_response'};
    {1, 'RESPONSE', 'INCORRECT', 'incorrect_response'};
};

tic
% Parallel Loop to process multiple sessions at once
parfor j = 1:numel(folders)
    for indx = 1:numel(sessionNames) - 2 % minus two to ignore the . and ..
        % Load current session
        [s, sessionName] = load_session(rootDir, indx);
        anatData = prepare_anat_data(s, 1);

        choice = folders{j}{1};
        lock = folders{j}{2};
        correct = folders{j}{3};
    
        % Sort spikes for MVGC
        %sort_spikes_three_d(s, anatData, sessionName, bin_size);

        % Get outcome as string 
        if choice == 1
            choice_name = "_left";
        elseif choice == 0
            choice_name = "_nogo";
        else
            choice_name = "_right";
        end

        if strcmp(correct, 'CORRECT')
            outcome = 1;
        else
            outcome = 0;
        end
    
        %sort_three_d_choices(s, anatData, sessionName, bin_size, choice, lock, correct, folders{j}{4});
        sort_three_d_outcomes(s, anatData, sessionName, bin_size, outcome, lock);
    
        %filename = strcat('processed/', 'spike_times_three_d', sessionName, lock, choice_name, correct,  '.mat');
        filename = strcat('processed/spike_times_three_d', sessionName, lock, correct,  '.mat');
        % Perform MVGC
        trigger_mvgc(rootDir, indx, filename,folders{j});
    end
end
toc % Display time taken