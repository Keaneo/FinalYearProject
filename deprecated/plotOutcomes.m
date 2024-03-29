function splitByDecision()

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


            % Example of how to use this setup
            % s is session - used like s.spikes.times
%             plot(s.spikes.times(1:10,1), 'r-*');
%             xlabel('Index')
%             ylabel('Time (seconds)')

            % Rename some variables for easier access
            stimOn = s.trials.visualStim_times;
            beeps = s.trials.goCue_times;
            feedbackTime = s.trials.feedback_times;
            intervals = s.trials.intervals;
            outcomes = s.trials.response_choice;
            contLeft = s.trials.visualStim_contrastLeft;
            contRight = s.trials.visualStim_contrastRight;
            spikeTimes = s.spikes.times;

            CORRECT_COLOUR = [0.1 1 0.1];
            WRONG_COLOUR = [1 0.1 0.1];

            figure;
            hold on;
            
%           Rescale the spiking data 
            minspike = min(spikeTimes(:));
            maxspike = max(spikeTimes(:));
            minbeeps = min(beeps(:));
            maxbeeps = max(beeps(:));

            rangespike = maxspike - minspike;
            rangebeep = maxbeeps - minbeeps;      
            plottableSpikes = (spikeTimes - minspike) / rangespike * rangebeep + minbeeps;

            % Rescale intervals and beeps to fit the size of the spiking
            % data vector
            scaleIntervals = length(plottableSpikes) / max(intervals(:,2));
            intervals = intervals .* scaleIntervals;

            scaleBeeps = length(plottableSpikes) / max(beeps);
            beeps = beeps .* scaleBeeps;

            %Plot the goCue times to establish plot axes
            xline(beeps);

            trials = [];
            
            %Loop each trial, calculate outcome of decision, paint
            %background with red or green to show trial over neuron
            %activity.
            for i = 1:size(intervals, 1)
                % Is the left contrast higher than the right?
                % This would make a right turn the correct one. And etc.
                if contLeft(i) > contRight(i)
                    correct = 1;
                elseif contLeft(i) < contRight(i)
                    correct = -1;
                elseif contLeft(i) == contRight(i)
                    correct = 0;
                end
                % If correct, paint a green square, otherwise do red.
                % Width of a square represent the trial length.
                if correct == outcomes(i)                    
                    patch([intervals(i,1) intervals(i,1) intervals(i,2) intervals(i,2)], [0 max(plottableSpikes) max(plottableSpikes) 0], CORRECT_COLOUR);
                    % Counting the spikes during this trial
                    % Needs refining into calculating the firing rate.
                    count = length(plottableSpikes(intervals(i,1):intervals(i,2)));
                    trials = [trials; count 1;];
                else
                    patch([intervals(i,1) intervals(i,1) intervals(i,2) intervals(i,2)], [0 max(plottableSpikes) max(plottableSpikes) 0], WRONG_COLOUR);
                    % Same as above
                    count = length(plottableSpikes(intervals(i,1):intervals(i,2)));
                    trials = [trials; count 0;];
                end
            end
            % Plot spiking over the trials
            plot(plottableSpikes);
            hold off;
        end    
    end
end