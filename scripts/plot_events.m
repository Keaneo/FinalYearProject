function plot_events(s, start_time, end_time, y_max)
    for j = 1:numel(s.trials.goCue_times)
        if(s.trials.goCue_times(j) >= start_time && s.trials.goCue_times(j) <= end_time)
            line([s.trials.goCue_times(j) s.trials.goCue_times(j)], [0 y_max], 'DisplayName', 'Go Cue');
        end
    end

    for j = 1:numel(s.trials.visualStim_times)
        if(s.trials.visualStim_times(j) >= start_time && s.trials.visualStim_times(j) <= end_time)
            line([s.trials.visualStim_times(j) s.trials.visualStim_times(j)], [0 y_max], 'Color', [0 0.8 0], 'DisplayName', '');
        end
    end

    for j = 1:size(s.trials.intervals, 1)
        if(s.trials.intervals(j, 1) >= start_time && s.trials.intervals(j, 1) <= end_time)
            line([s.trials.intervals(j, 1) s.trials.intervals(j, 1)], [0 y_max], 'Color', [0.2 0 0]);
        end
        if(s.trials.intervals(j, 2) >= start_time && s.trials.intervals(j, 2) <= end_time)
            line([s.trials.intervals(j, 2) s.trials.intervals(j, 2)], [0 y_max], 'Color', [0.2 0 0]);
        end
    end
end
