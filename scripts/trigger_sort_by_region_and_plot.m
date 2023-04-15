% SETUP AND VARIABLE DEFAULTS
%================================================
% rootDir = './allData'; % Directory to find Steinmetz data
% nProbe = 1; % Probe Number (0-indexed)
% region_names = ["MOs", "ACA", "LS", "root"]; % Brain Regions to analyse
% % Time range
% start_time = 65;
% end_time = 75;
% % Size (in seconds) of bin to get firing rate for
% bin_size = 0.05;

function trigger_sort_by_region_and_plot(rootDir, nProbe, region_names, start_time, end_time, bin_size)

    %Load Session from Steinmetz dataset
    [s, sessionName] = load_session(rootDir);
    anatData = prepare_anat_data(s, nProbe);
    
    % Sort the data into region by cluster
    brain_region_spike_times = sort_spikes(s, anatData, sessionName);
    
    valid_region_names = cell(1, numel(region_names));
    
    % Ensure listed regions are present
    for i = 1:numel(region_names)
        valid_region_names{i} = regexprep(region_names{i}, '[^a-zA-Z0-9]', '');
        if ~isfield(brain_region_spike_times, valid_region_names{i})
            error('One of the specified region_names was not found in the brain_region_spike_times struct.');
        end
    end
    
    total_regions = numel(region_names);
    
    % PLOTTING SPIKES
    %================================================
    question = 'Plot Spikes?';
    title = 'Yes or No';
    
    % Ask if user wants to plot spikes.
    userResponse = yes_no_button(question, title);
    
    % Process the user's response
    switch userResponse
        case 'Yes'
            disp('User selected "Yes".');
    
            figure;
            ax = gobjects(total_regions, 1);
            
            % Iterate regions
            for i = 1:total_regions           
                region = brain_region_spike_times.(valid_region_names{i});
                
                % Create a subplot for each region
                ax(i) = subplot(total_regions, 1, i);
                plot_spikes(region, s, start_time, end_time);
                box off;
                
                % Remove X axis tick labels for all except the bottom subplot
                if i < total_regions
                    set(ax(i), 'XTickLabel', {});
                end
                % Label the y axis with region name.
                ylabel(region_names(i));
            end
            
            % Label x-axis units
            xlabel('Time (s)');
            
            % Adjust spacing between subplots to zero
    %         for i = 1:(total_regions-1)
    %             pos1 = get(ax(i), 'Position');
    %             pos2 = get(ax(i+1), 'Position');
    %             pos1(2) = pos2(2) + pos2(4);
    %             set(ax(i), 'Position', pos1);
    %         end
            
        case 'No'
            disp('User selected "No".');
            % Do nothing;
        otherwise
            disp('User closed the dialog without selecting an option.');
            % Do nothing;
    end
    
    
    % FIRING RATES
    %================================================
    
    question = 'Get Firing Rates?';
    title = 'Yes or No';
    
    % Ask user if they want to get the firing rates
    userResponse = yes_no_button(question, title);
    
    % Process the user's response
    switch userResponse
        case 'Yes'
            disp('User selected "Yes".');
            firing_rates = avg_across_regions(brain_region_spike_times, region_names, start_time, end_time, bin_size);
        case 'No'
            disp('User selected "No".');
            % Do nothing;
        otherwise
            disp('User closed the dialog without selecting an option.');
            % Do nothing;
    end
    
    % Plot the firing rates.
    
    figure(2);
    ax = gobjects(total_regions, 1);
    for i = 1:total_regions
        % Setup subplot
        ax(i) = subplot(total_regions, 1 ,i);
    
        % Get region
        region_names = fieldnames(firing_rates);
        region_name = region_names{i};
    
        % Plot firing rates
        plot(firing_rates.(region_name));
        box off;
    
        % Label the y axis with region name.
        ylabel(region_names(i));
    end

end
