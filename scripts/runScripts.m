% SETUP AND VARIABLE DEFAULTS
%================================================
rootDir = './allData'; % Directory to find Steinmetz data
nProbe = 1; % Probe Number (0-indexed)
region_names = ["MOs", "ACA", "LS", "root"]; % Brain Regions to analyse
%NOT USED FOR LOOP ^^^^
% % Time range
start_time = 0;
end_time = 50;
% % Size (in seconds) of bin to get firing rate for
bin_size = 0.005;

% d = dir(fullfile(rootDir, '*')); 
% d = d([d.isdir]); 
% sessionNames = {d.name};
% tic
% parfor indx = 1:numel(sessionNames) - 2 % minus two to ignore the . and ..
%     %trigger_sorting_all(rootDir, indx);
%     trigger_mvgc(rootDir, nProbe, region_names, start_time, end_time, bin_size, indx);
% end
% toc


%trigger_sort_by_region_and_plot(rootDir, nProbe, region_names, start_time, end_time, bin_size);

 indx = 20
 trigger_mvgc(rootDir, nProbe, region_names, start_time, end_time, bin_size, indx);