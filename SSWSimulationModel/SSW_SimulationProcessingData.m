clear all; close all;

% Load the data from the specified Excel files
filename = 'C:\Users\pablo\Desktop\InvestigacionUSFQ\SSWCompleteAnalysis\SingleSolitaryWaveAnalysis\SSWSimulationModel\SSW_Saw_Bones_Callibration_Data\PCF_5_exp_data.xlsx';
data = readtable(filename);

filename_2 = 'C:\Users\pablo\Desktop\InvestigacionUSFQ\SSWCompleteAnalysis\SingleSolitaryWaveAnalysis\SSWSimulationModel\SSW_Saw_Bones_Callibration_Data\PCF_5_num_data.xlsx';
data_2 = readtable(filename_2);

% Extract time and normalized force columns for file 1
time_1 = data{:, 1}; % Use curly braces to extract as numeric array
force_1 = data{:, 2}; % Use curly braces to extract as numeric array

% Replace negative values with 0 for file 1
force_1(force_1 < 0) = 0;

% Extract time and normalized force columns for file 2
time_2 = data_2{:, 1}; % Use curly braces to extract as numeric array
force_2 = data_2{:, 2}; % Use curly braces to extract as numeric array

% Define downsampling factor (average every 5 points)
downsample_factor = 18;

% Downsample data from file 2 (filename_2) by averaging every 5 points
force_2_downsampled = arrayfun(@(i) mean(force_2(i:min(i+downsample_factor-1, length(force_2)))), 1:downsample_factor:length(force_2)-rem(length(force_2), downsample_factor));

% Downsample time accordingly
time_2_downsampled = time_2(1:downsample_factor:end-downsample_factor+1);

% Plot the data
figure;
hold on; % Allow multiple plots on the same axes
plot(time_1, force_1); % Plot data from file 1
plot(time_2, force_2); % Plot data from file 2
hold off; % Release the hold on the axes
xlabel('Time');
ylabel('Normalized Force');
title('Data from files');
legend('File 1', 'File 2'); % Add a legend to differentiate between the files

% Find peaks in force_1
[peaks_1, locs_1] = findpeaks(force_1, 'SortStr', 'descend');

% Find the second highest peak in force_1
second_peak_index_1 = 1; % Change this index as needed for different peaks
time_peak_1 = time_1(locs_1(second_peak_index_1));

% Find peaks in force_2_downsampled
[peaks_2, locs_2] = findpeaks(force_2_downsampled, 'SortStr', 'descend');

% Find the second highest peak in force_2_downsampled
second_peak_index_2 = 1; % Change this index as needed for different peaks
time_peak_2 = time_2_downsampled(locs_2(second_peak_index_2));

% Calculate the time difference between the second highest peaks
time_shift = time_peak_1 - time_peak_2;

% Shift the time vector for force_2_downsampled by the time difference to align the peaks
time_2_downsampled_aligned = time_2_downsampled + time_shift;

% Define the limits of the x-axis window
x_min = -0.00045;% Your minimum x-value for the window;
x_max = 0.0022;% Your maximum x-value for the window;

% Find the indices of data within the x-axis window for both force_1 and force_2_downsampled_aligned
indices_1 = find(time_1 >= x_min & time_1 <= x_max);
indices_2 = find(time_2_downsampled_aligned >= x_min & time_2_downsampled_aligned <= x_max);

% Plot the aligned data within the x-axis window
figure;
hold on;
plot(time_1(indices_1), force_1(indices_1));
plot(time_2_downsampled_aligned(indices_2), force_2_downsampled(indices_2));
hold off;
xlabel('Time');
ylabel('Normalized Force');
title('Aligned Data within X-axis Window');
legend('File 1', 'File 2 (Downsampled)');


% Transpose the inputs if they are row vectors
time_1_aligned_column = time_1(indices_1).';
force_1_downsampled_column = force_1(indices_1).';
time_2_aligned_column = time_2_downsampled_aligned(indices_2);
force_2_downsampled_column = force_2_downsampled(indices_2).';
% Create new variables for processed data
processed_data_1 = table(time_1(indices_1), force_1(indices_1));
processed_data_2 = table(time_2_aligned_column, force_2_downsampled_column);

% Define new filename with "processed" appended
[filepath, name, ext] = fileparts(filename);
new_filename = fullfile(filepath, "All_PCF_data_processed.xlsx");

% Write processed_data
writetable(processed_data_1, new_filename, 'Sheet', "PCF05_exp");
writetable(processed_data_2, new_filename, 'Sheet', "PCF05_num");

disp('Processed data saved to the same Excel file with different sheets');


