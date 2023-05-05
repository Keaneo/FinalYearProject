% SETUP AND VARIABLE DEFAULTS 
%================================================
rootDir = './allData'; % Directory to find Steinmetz data
nProbe = 1; % Probe Number (0-indexed)
region_names = ["MOs", "ACA", "LS", "root"]; % Brain Regions to analyse
%NOT USED FOR LOOP ^^^^
% % Time range
start_time = 0;
end_time = 1000;
% % Size (in seconds) of bin to get firing rate for
bin_size = 0.005;

d = dir(fullfile(rootDir, '*')); 
d = d([d.isdir]); 
sessionNames = {d.name};
tic
% trigger_sorting(rootDir, 1);
    parfor indx = 1:numel(sessionNames) - 2 % minus two to ignore the . and ..
%          try
%         trigger_sorting_all(rootDir, indx, bin_size);
        trigger_mvgc(rootDir, nProbe, region_names, start_time, end_time, bin_size, indx);
%          catch 
%             
%         end
    end

toc


%trigger_sort_by_region_and_plot(rootDir, nProbe, region_names, start_time, end_time, bin_size);

%indx = 17
%trigger_mvgc(rootDir, nProbe, region_names, start_time, end_time, bin_size, indx);