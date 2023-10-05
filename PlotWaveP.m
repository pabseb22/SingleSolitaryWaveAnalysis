% Absolute path to the folder where CSV files are located
folder_path = 'C:\Users\pablo\Desktop\InvestigacionUSFQ\SingleSolitaryWaveAnalysis\ResultadosVelocidadOndaP';

% File index to plot (change to the file you want to visualize)
file_index = 3;

% Current file name
file_name = sprintf('ProbetaM1_Run#%d.csv', file_index);

% Full path to the CSV file
file_path = fullfile(folder_path, file_name);

% Load data from the CSV file
data = csvread(file_path, 11, 0); % Ignore the first 10 header rows

% Extract columns for time, signal1, and signal2
time = data(:, 1); % First column
signal1 = data(:, 2); % Second column
signal2 = data(:, 3); % Third column

% Calculate the cross-correlation between the two signals
cross_correlation = xcorr(signal1 - mean(signal1), signal2 - mean(signal2));

% Find the index in the cross-correlation where the maximum value occurs
[max_value, max_index] = max(abs(cross_correlation));

% Calculate the lag in terms of sample indices
lag = max_index - 1;

% Calculate the total time span
total_time = time(end) - time(1);

% Calculate the sampling frequency (fs)
num_samples = length(time);
fs = (num_samples - 1) / total_time; % Subtract 1 because there is one less interval than samples

% Convert the lag to time difference in microseconds
time_difference_ms = lag / fs * 1e6;

% Plot both signals aligned on the x-axis (y = 0)
figure;
plot(time, signal1 - mean(signal1), 'b', time, signal2 - mean(signal2), 'r');
title('Signals 1 and 2 (Aligned on Y-axis)');
xlabel('Time (s)');
ylabel('Amplitude');
legend('Signal 1', 'Signal 2');

% Display the sampling frequency and time difference
fprintf('Sampling frequency (fs): %.2f Hz.\n', fs);
fprintf('Time difference for file %d: %.2f microseconds.\n', file_index, time_difference_ms);
