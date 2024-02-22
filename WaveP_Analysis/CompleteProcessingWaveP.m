close all;
clear all;

% Absolute path to the folder where CSV files are located
folder_path = 'C:\Users\pablo\Desktop\InvestigacionUSFQ\SSWCompleteAnalysis\ResultadosOndaP\ResultadosVelocidadOndaPProctorsPabloMajo';

% Number of runs to analyze
num_runs = 5;

% Array to store time delays
time_delays_smooth = zeros(1, num_runs);
time_delays_original = zeros(1, num_runs);

for file_index = 1:num_runs
    % Current file name
    file_name = sprintf('M1_25_Est_Run#%d.csv', file_index);

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
    sigma_2 = 10;

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

    signal1 = imgaussfilt(signal1, sigma_2);
    signal2 = imgaussfilt(signal2, sigma_2);

    threshold = 0.2;
    threshold_2 = 0.02;

    % Find the first peak in the absolute values of smoothed signals
    [~, loc1_smooth] = findpeaks(abs(signal1_smooth), 'MinPeakHeight', threshold, 'NPeaks', 1);
    [~, loc2_smooth] = findpeaks(abs(signal2_smooth), 'MinPeakHeight', threshold, 'NPeaks', 1);

    % Find the first peak in the absolute values of original signals
    [~, loc1_original] = findpeaks(abs(signal1), 'MinPeakHeight', threshold_2, 'NPeaks', 1);
    [~, loc2_original] = findpeaks(abs(signal2), 'MinPeakHeight', threshold_2, 'NPeaks', 1);

    % Get the time of the first peak in signals 1 and 2 for smoothed signals
    time_peak1_smooth = time(loc1_smooth);
    time_peak2_smooth = time(loc2_smooth);

    % Get the time of the first peak in signals 1 and 2 for original signals
    time_peak1_original = time(loc1_original);
    time_peak2_original = time(loc2_original);

    % Calculate the time delays
    time_delay_smooth = time_peak2_smooth - time_peak1_smooth;
    time_delay_original = time_peak2_original - time_peak1_original;

    % Create a new figure with two subplots side by side
    figure('Position', [100, 250, 1200, 400]); % Adjust the position and size as needed

    % Subplot for Aligned, Normalized, and Smooth Signals with identified peaks
    subplot(1, 2, 1); % 1 row, 2 columns, first subplot
    plot(time, signal1_smooth, 'b', time, signal2_smooth, 'r', time_peak1_smooth, signal1_smooth(loc1_smooth), 'bo', time_peak2_smooth, signal2_smooth(loc2_smooth), 'ro');
    title('Aligned, Normalized, and Smooth Signals');
    xlabel('Time (s)');
    ylabel('Normalized Amplitude (Aligned)');
    legend('Signal 1', 'Signal 2', 'Peak in Signal 1', 'Peak in Signal 2');

    % Subplot for Original Signals with identified peaks
    subplot(1, 2, 2); % 1 row, 2 columns, second subplot
    plot(time, signal1, 'b', time, signal2, 'r', time_peak1_original, signal1(loc1_original), 'bo', time_peak2_original, signal2(loc2_original), 'ro');
    title('Original Signals');
    xlabel('Time (s)');
    ylabel('Amplitude');
    legend('Signal 1', 'Signal 2', 'Peak in Signal 1', 'Peak in Signal 2');

    % Display the time delays for smoothed signals
    fprintf('File %d - Time delay #1: %.3f micro-seconds.\n', file_index, time_delay_smooth*1e6);

    % Display the time delays for original signals
    fprintf('File %d - Time delay #2: %.3f micro-seconds.\n', file_index, time_delay_original*1e6);

    % Ask for user input to confirm peaks
    user_input = input('Are the identified peaks correct? (y/n): ', 's');
    
    % Check user input
    if strcmpi(user_input, 'y')
        % Save time delays for correct runs
        time_delays_smooth = [time_delays_smooth, time_delay_smooth];
        time_delays_original = [time_delays_original, time_delay_original];
    else
        fprintf('Peaks not confirmed. Skipping this run.\n');
    end

    % Close the current figure
    close gcf;
end

% Check if there are correct time delays
if ~isempty(time_delays_smooth)
    % Remove zeros from the arrays
    nonzeros_smooth = nonzeros(time_delays_smooth);
    nonzeros_original = nonzeros(time_delays_original);

    % Check if there are non-zero values
    if ~isempty(nonzeros_smooth)
        % Display the overall time delays
        fprintf('\nOverall Time Delays:\n');
        fprintf('Time delay #1: %.3f micro-seconds.\n', mean(nonzeros_smooth)*1e6);
        fprintf('Time delay #2: %.3f micro-seconds.\n', mean(nonzeros_original)*1e6);
    else
        fprintf('\nAll time delays are zero. Cannot calculate mean.\n');
    end
else
    fprintf('\nNo correct time delays to display.\n');
end