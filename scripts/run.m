% SETUP AND VARIABLE DEFAULTS
%================================================
rootDir = './allData'; % Directory to find Steinmetz data
nProbe = 1; % Probe Number (0-indexed)
region_names = ["MOs", "ACA", "LS", "root"]; % Brain Regions to analyse
% % Time range
start_time = 65;
end_time = 75;
% % Size (in seconds) of bin to get firing rate for
bin_size = 0.05;

trigger_sort_by_region_and_plot(rootDir, nProbe, region_names, start_time, end_time, bin_size);