close all; clear all;
%Folder Definition

folder_path = "C:\Users\pablo\Desktop\InvestigacionUSFQ\SSWCompleteAnalysis\ResultadosBolazos\ResultadosBolazosProctorsPabloMajo2";
file_name = 'M4_25_Mod_ConPlaca';
desiredPoisson = 0.4;

% Absolute path to the folder where CSV files are located
folder_path_WaveP = "C:\Users\pablo\Desktop\InvestigacionUSFQ\SSWCompleteAnalysis\ResultadosOndaP\ResultadosVelocidadOndaPProctorsPabloMajo2";
% Base name for the files
base_name = 'M4_25_Mod_Run#';
% Number of runs to analyze
num_runs = 5;

% Poisson's ratio values used in the simulation
pois = [0.1, 0.2, 0.3, 0.4, 0.5];

% Young's modulus values used in the simulation
mody = [5e6, 25e6, 50e6, 100e6, 200e6, 300e6, 400e6];

file_path = fullfile(folder_path, file_name);
load(file_path);

% Load TOF_data from the MAT file
load('C:\Users\pablo\Desktop\InvestigacionUSFQ\SSWCompleteAnalysis\SingleSolitaryWaveAnalysis\SSWSimulationModel\TOF.mat', 'TOF_data');


% Specify the desired Poisson's ratio for interpolation
timeDifferences = [];  % Initialize an empty array to store the time differences

figures = length(scanData);

daqfix = 1;
%daqfix = 100/51.8;

% Part 1: Process Voltage Signal Data

for i = 1:numel(scanData)
    % Extract data for each figure
    data = scanData{i};
    xdata = data(:, 1); % Assuming the first column contains the x-values
    ydata = data(:, 2); % Assuming the second column contains the y-values
    
    % Plot data for each figure
    subplot(1, figures, i);
    plot(xdata, ydata);
    xlabel('X-axis Label'); % Add appropriate labels
    ylabel('Y-axis Label');
    title(['Data Plot ' num2str(i)]);
    grid on; % Add a grid for better visualization

    % Filter the data by applying a threshold to remove small peaks
    threshold = 0.2; % Adjust the threshold value as needed
    filteredYData = ydata;
    filteredYData(ydata < threshold) = 0;

    % Find peaks in the filtered y-data
    [peaks, peakIndices] = findpeaks(filteredYData);

    % Access the peak values and their corresponding x-values (timestamps)
    peakXData = xdata(peakIndices);

    if numel(peaks) >= 2
        % Find the two highest peaks
        [sortedPeaks, sortedIndices] = sort(peaks, 'descend');
        highestPeaks = sortedPeaks(1:2);
        highestPeakIndices = peakIndices(sortedIndices(1:2));
        highestPeakXData = peakXData(sortedIndices(1:2));

        % Calculate the difference between the x-values of the two highest peaks (time differences)
        timeDifference = abs(diff(highestPeakXData));

        % Add markers for the highest peaks to the plot
        hold on;
        scatter(highestPeakXData, highestPeaks, 'ro', 'MarkerFaceColor', 'r');

        timeDifferences = [timeDifferences; timeDifference];  % Append the time difference to the array
    else
        disp(['Data Group ' num2str(i) ': Less than two peaks detected in the filtered voltage signal.']);
    end
end

% Part 2: Plot TOF Data

% Convert the cell array to a numeric matrix
numericTOF_data = cell2mat(TOF_data);

% Perform linear interpolation for the desired Poisson's ratio
interp_values = interp1(pois, numericTOF_data, desiredPoisson, 'linear', 'extrap');

% Display the interpolated values for the desired Poisson's ratio
% disp(['Interpolated values for Poisson''s ratio ' num2str(desiredPoisson) ':']);
% disp(interp_values);

% Part 1.2: Interpolation for Young's Modulus

% Iterate through each time difference
for idx = 1:length(timeDifferences)
    % Use the idx-th time difference for interpolation
    desiredTOFValue = timeDifferences(idx);
    A_TOF_Values{idx} = desiredTOFValue;
    % Perform linear interpolation for the desired Poisson's ratio along columns
    interp_mody_values = interp1(interp_values, mody, desiredTOFValue, 'linear', 'extrap');
    A_Mod_Interpolated{idx} = interp_mody_values/1e6;
        % Check if the interpolated value is within bounds
    if interp_mody_values >= min(mody) && interp_mody_values <= max(mody)
        % Display the interpolated Young's Modulus for the current TOF value
        disp(['TOF: ' num2str(desiredTOFValue) '-- E: ' num2str(interp_mody_values/1e6) ' Mpa']);
    else
        disp(['TOF: ' num2str(desiredTOFValue) ' -- Interpolated E is out of bounds']);
    end
end

% Create a new figure for the final plot
figure('Position', [100, 250, 800, 400]); % Adjust the position and size as needed
hold on;

% Define a set of colors for each run
runColors = lines(num_runs);
legendStrings = cell(1, num_runs);

for file_index = 1:num_runs
    % Current file name
    file_name = sprintf('%s%d.csv', base_name, file_index);

    % Full path to the CSV file
    file_path = fullfile(folder_path_WaveP, file_name);

    % Load data from the CSV file
    data = csvread(file_path, 11, 0); % Ignore the first 10 header rows

    % Extract columns for time, signal1, and signal2
    time = data(:, 1); % First column
    signal1 = data(:, 2); % Second column
    signal2 = data(:, 3); % Third column
    sigma = 10;

    signal1 = imgaussfilt(signal1, sigma);
    signal2 = imgaussfilt(signal2, sigma);
    threshold_Peaks = 0.02;

    % Find the first peak in the absolute values of original signals
    [~, loc1_original] = findpeaks(abs(signal1), 'MinPeakHeight', threshold_Peaks, 'NPeaks', 1);
    [~, loc2_original] = findpeaks(abs(signal2), 'MinPeakHeight', threshold_Peaks, 'NPeaks', 1);

    % Get the time of the first peak in signals 1 and 2 for original signals
    time_peak1_original = time(loc1_original);
    time_peak2_original = time(loc2_original);

    % Calculate the time delays
    time_delay_original = (time_peak2_original - time_peak1_original)*1e6;
    A_TV_Results{file_index} = time_delay_original;

    % Display the time delays for original signals
    fprintf('File %d : %.3f micro-seconds.\n', file_index, time_delay_original);

    % Plot the detected peaks for each run with different colors
    plot(time, signal1, 'Color', runColors(file_index, :));
    plot(time, signal2, 'Color', runColors(file_index, :));
    scatter(time_peak1_original, signal1(loc1_original), 'MarkerEdgeColor', runColors(file_index, :), 'Marker', 'o');
    scatter(time_peak2_original, signal2(loc2_original), 'MarkerEdgeColor', runColors(file_index, :), 'Marker', 'o');
    %plot(time, signal1, time, signal2, time_peak1_original, signal1(loc1_original), 'bo', time_peak2_original, signal2(loc2_original), 'ro', 'Color', runColors(file_index, :));
    % Create legend string for the current run
    %legendStrings{file_index} = ['Run ' num2str(file_index)];
end
title('Detected Peaks in Original Signals');
xlabel('Time (s)');
ylabel('Amplitude');
grid on;
hold off;

% Add a legend outside the loop using the legendStrings cell array
%legend(legendStrings, 'Location', 'best');