% Absolute path to the folder where CSV files are located
folder_path = 'C:\Users\pablo\Desktop\InvestigacionUSFQ\SingleSolitaryWaveAnalysis\ResultadosVelocidadOndaP';

% Number of files to process
num_files = 5;

% Initialize an array to store the lags for each file
lags = zeros(num_files, 1);

% Loop to process each file
for i = 1:num_files
    % Current file name
    file_name = sprintf('ProbetaM1_Run#%d.csv', i);

    % Full path to the CSV file
    file_path = fullfile(folder_path, file_name);

    % Load data from the CSV file
    data = csvread(file_path, 11, 0); % Ignore the first 10 header rows

    % Extract columns for time, signal1, and signal2
    time = data(:, 1); % First column
    signal1 = data(:, 2); % Second column
    signal2 = data(:, 3); % Third column

    % Calculate the cross-correlation between the two signals
    cross_correlation = xcorr(signal1, signal2);

    % Find the index in the cross-correlation where the maximum value occurs
    [max_value, max_index] = max(abs(cross_correlation));

    % Calculate the lag in terms of sample indices
    lag = max_index - 1;

    % Store the lag in the lags array
    lags(i) = lag;
end

% Calculate the average of the lags
average_lag = mean(lags);

% Display the results
fprintf('Lags for the 5 files:\n');
disp(lags);

% Calculate the total time span
total_time = time(end) - time(1);

% Calculate the sampling frequency (fs)
num_samples = length(time);
fs = (num_samples - 1) / total_time; % Subtract 1 because there is one less interval than samples


% Convert the average lag 
average_lag_ms = average_lag / fs * 1e6; % 1e6 microseconds in a second

fprintf('Average time difference: %.2f microseconds.\n', average_lag_ms);

