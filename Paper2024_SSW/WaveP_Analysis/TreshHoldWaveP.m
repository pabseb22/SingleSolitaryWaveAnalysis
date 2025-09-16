% Absolute path to the folder where CSV files are located
folder_path = 'C:\Users\pablo\Desktop\InvestigacionUSFQ\SSWCompleteAnalysis\ResultadosVelocidadOndaP';

% File index to plot (change to the file you want to visualize)
file_index = 1;

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

% Normalize the signals by dividing by their maximum absolute values
signal1_normalized = signal1 / max(abs(signal1));
signal2_normalized = signal2 / max(abs(signal2));

% Define the standard deviation (sigma) for the Gaussian filter
sigma = 50; % Adjust as needed

% Apply a Gaussian filter to smooth signal1
signal1_smooth = imgaussfilt(signal1_normalized, sigma);
signal2_smooth = imgaussfilt(signal2_normalized, sigma);

% Find the start time of the first peak in signal 1 and signal 2
% Determine the vertical shift needed for alignment
vertical_shift_normalized = -signal1_normalized(1);
vertical_shift_smooth = -signal1_smooth(1);

% Align both signals to Y = 0
signal1_smooth = signal1_smooth + vertical_shift_smooth;
signal1_normalized = signal1_normalized + vertical_shift_normalized;

threshold_1 = 0.015;
threshold_2 = 0.015;

% Calculate the time delay between the two start times
time_delay = time(find(abs(signal1_smooth) > threshold_1, 1)) - time(find(abs(signal2_smooth) > threshold_2, 1));
time_delay = abs(time_delay)*1000000; %transform to microseconds

% Create a new figure with two subplots side by side
figure('Position', [100, 250, 1200, 400]); % Adjust the position and size as needed

% Subplot for Aligned and Smoothed Signals
subplot(1, 3, 1); % 1 row, 2 columns, first subplot
plot(time, signal1, 'b', time, signal2, 'r');
title('Original Signals 1 and 2');
xlabel('Time (s)');
ylabel('Amplitude');
legend('Signal 1', 'Signal 2');


% Subplot for Original Signals
subplot(1, 3, 2); % 1 row, 2 columns, second subplot
plot(time, signal1_normalized, 'b', time, signal2_normalized, 'r');
title('Aligned and Normalized Signals 1 and 2');
xlabel('Time (s)');
ylabel('Normalized Amplitude (Aligned)');
legend('Signal 1', 'Signal 2');


% Subplot for Original Signals
subplot(1, 3, 3); % 1 row, 2 columns, second subplot
plot(time, signal1_smooth, 'b', time, signal2_smooth, 'r');
title('Aligned, Normalized and Smooth Signals 1 and 2');
xlabel('Time (s)');
ylabel('Normalized Amplitude (Aligned)');
legend('Signal 1', 'Signal 2');


% Display the time delay
fprintf('Time delay between the start of the first peak in signal 1 and signal 2: %.2f microseconds.\n', time_delay);
