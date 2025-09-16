% Absolute path to the folder where CSV files are located
folder_path = 'C:\Users\pablo\Desktop\InvestigacionUSFQ\SSWCompleteAnalysis\ResultadosVelocidadOndaPSueloCeramica';

% File index to plot (change to the file you want to visualize)
file_index = 5;

% Current file name
file_name = sprintf('ProbetaM2_56_Run#%d.csv', file_index);

% Full path to the CSV file
file_path = fullfile(folder_path, file_name);

% Load data from the CSV file
data = csvread(file_path, 11, 0); % Ignore the first 10 header rows

% Extract columns for time, signal1, and signal2
time = data(:, 1); % First column
signal1 = data(:, 2); % Second column
signal2 = data(:, 3); % Third column

% Normalize the signals by dividing by their maximum absolute values
signal1_normalized = signal1 / max(abs(signal1));
signal2_normalized = signal2 / max(abs(signal2));

% Define the standard deviation (sigma) for the Gaussian filter
sigma = 50; % Adjust as needed

% Apply a Gaussian filter to smooth signal1
%signal1_normalized = imgaussfilt(signal1_normalized, sigma);
%signal2_normalized = imgaussfilt(signal2_normalized, sigma);

% Find the start time of the first peak in signal 1 and signal 2
% Determine the vertical shift needed for alignment
vertical_shift = -signal1_normalized(1);

% Align both signals to Y = 0
signal1_normalized = signal1_normalized + vertical_shift;

% Calculate the cross-correlation between the two normalized signals
cross_correlation = xcorr(signal1_normalized, signal2_normalized);

% Find the index in the cross-correlation where the maximum value occurs
[max_value, max_index] = max(abs(cross_correlation));

% Calculate the lag in terms of sample indices
lag = max_index;

% Calculate the total time span
total_time = time(end) - time(1);

% Calculate the sampling frequency (fs)
num_samples = length(time);
fs = (num_samples - 1) / total_time; % Subtract 1 because there is one less interval than samples

% Convert the lag to time difference in microseconds
time_difference_ms = lag / fs * 1e6;

% Plot both normalized signals
figure;
plot(time, signal1_normalized, 'b', time, signal2_normalized, 'r');
title('Normalized Signals 1 and 2');
xlabel('Time (s)');
ylabel('Normalized Amplitude');
legend('Signal 1', 'Signal 2');

% Display the sampling frequency and time difference
fprintf('Sampling frequency (fs): %.2f Hz.\n', fs);
fprintf('Time difference for file %d: %.2f microseconds.\n', file_index, time_difference_ms);
