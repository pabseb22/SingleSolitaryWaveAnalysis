%Define File Group
num_probeta = 2;

% Absolute path to the folder where CSV files are located
folder_path = 'C:\Users\pablo\Desktop\InvestigacionUSFQ\SSWCompleteAnalysis\ResultadosVelocidadOndaP';

% Number of files to process
num_runs = 5;

% Initialize an array to store the lags for each file
time_delays = zeros(num_runs, 1);

% Loop to process each file
for i = 1:num_runs
    % Current file name
    file_name = sprintf('ProbetaM%d_Run#%d.csv', num_probeta, i);
    
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
    fprintf('Time difference #%.f: %.2f microseconds.\n', i,time_delay);

    % Store the lag in the lags array
    time_delays(i) = time_delay;
end

% Calculate the average of the lags
average_time_delays = mean(time_delays);

% Display the results
fprintf('Average time difference: %.2f microseconds.\n', average_time_delays);

