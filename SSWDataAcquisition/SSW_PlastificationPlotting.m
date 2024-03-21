close all;
folder_path = 'C:\Users\pablo\Desktop\InvestigacionUSFQ\SSWCompleteAnalysis\ResultadosBolazos\ResultadosBolazosProctorsPabloMajo2';
% file_name = 'M3_25_Mod_SinPlaca';
file_name = 'M3_25_Mod_ConPlaca';

% manualMaxXValues = [21.1643, 21.164, 21.164, 21.164];
manualMaxXValues = [NaN, NaN, NaN, NaN, NaN];

threshold = 0.00005;

file_path = fullfile(folder_path, file_name);

load(file_path);

disp(length(scanData))

% Assuming you have a 1x3 cell array called scanData
figure;

timeDifferences = [];  % Initialize an empty array to store the time differences
figures = 5;

% Create a single subplot for all the data
subplot(1, 1, 1);
hold on;

legendEntries = {};  % Initialize legend entries

% Find the time shift needed to align the first peaks
firstPeaks = zeros(1, figures);
for i = 2:figures
    data = scanData{i};
    xdata = data(:, 1);
    ydata = data(:, 2);

    % Filter the data by applying a threshold to remove small peaks
    filteredYData = ydata;
    filteredYData(ydata < threshold) = 0;

    % Find peaks in the filtered y-data
    [peaks, peakIndices] = findpeaks(filteredYData);

    % Access the peak values and their corresponding x-values (timestamps)
    peakXData = xdata(peakIndices);

    if ~isempty(peakXData)
        firstPeaks(i) = peakXData(1);
    else
        disp(['Data Group ' num2str(i) ': No peaks detected in the filtered voltage signal.']);
    end
end

% Find the mean of the first peaks
meanFirstPeak = mean(firstPeaks);

% Plot each graph with the necessary time shift
for i = 2:figures
    data = scanData{i};
    xdata = data(:, 1);
    ydata = data(:, 2);

    % Filter the data by applying a threshold to remove small peaks
    filteredYData = ydata;
    filteredYData(ydata < threshold) = 0;

    % Apply smoothing using imgaussfilt
    sigma = 5; % You can adjust the smoothing parameter as needed
    smoothedYData = imgaussfilt(filteredYData, sigma);

    % Find peaks in the filtered y-data
    [peaks, peakIndices] = findpeaks(filteredYData);

    % Access the peak values and their corresponding x-values (timestamps)
    peakXData = xdata(peakIndices);

    if ~isempty(peakXData)
        [sortedPeaks, sortedIndices] = sort(peaks, 'descend');
        highestPeaks = sortedPeaks(1:2);
        highestPeakIndices = peakIndices(sortedIndices(1:2));
        highestPeakXData = peakXData(sortedIndices(1:2));

        % Calculate the difference between the x-values of the two highest peaks (time differences)
        timeDifference = abs(diff(highestPeakXData));

        % Add markers for the highest peaks to the plot
        timeShift = meanFirstPeak - highestPeakXData(1);

        % Manually adjust the max x-value if specified
        xdata = xdata + timeShift;
        if ~isnan(manualMaxXValues(i))
            manualMaxXValues(i);
            cutIndex = find(xdata > manualMaxXValues(i), 1);
            xdata = xdata(1:cutIndex - 1);
            smoothedYData = smoothedYData(1:cutIndex - 1);
        end

        % Align the entire graph using the calculated time shift
        plot(xdata , smoothedYData, 'LineWidth', 1.2);

        % Add entry to the legend
        legendEntries = [legendEntries, ['TOF #' num2str(i-1)]];
    else
        disp(['Data Group ' num2str(i) ': No peaks detected in the filtered voltage signal.']);
    end
end

% Set labels and title
% xlabel('X-axis Label');
% ylabel('Y-axis Label');
title('Using Plate Evidence');
grid on;

% Set x-axis limits to fit the entire graph
% xlim([min(xdata)+0.0003, max(xdata)+0.0002]);
xlim([min(xdata)+0.0003, max(xdata)-0.0013]);

% Add legend
legend(legendEntries, 'Location', 'Best');

hold off; % Release the hold on the plot
