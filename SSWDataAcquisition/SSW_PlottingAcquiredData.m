folder_path = 'C:\Users\pablo\Desktop\InvestigacionUSFQ\SSWCompleteAnalysis\ResultadosBolazos\ResultadosBolazosProctorsPabloMajo2';
close all;
daqfix = 1; 
file_name = 'M4_56_Mod_ConPlaca';
% file_name = 'M4_56_Mod_SinPlaca';
threshold = 0.00005;

file_path = fullfile(folder_path, file_name);
    
load(file_path);

% Assuming you have a 1x3 cell array called scanData
%figure;

timeDifferences = [];  % Initialize an empty array to store the time differences
figures = length(scanData);
for i = 1:numel(scanData)
    data = scanData{i};
    xdata = data(:, 1); % Assuming the first column contains the x-values
    ydata = data(:, 2); % Assuming the second column contains the y-values
    subplot(1, figures, i);
    plot(xdata, ydata);
    xlabel('X-axis Label'); % Add appropriate labels
    ylabel('Y-axis Label');
    title(['Data Plot ' num2str(i)]);
    grid on; % Add a grid for better visualization

    % Filter the data by applying a threshold to remove small peaks
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

        % Display the time difference between the two highest peaks
        disp(['Timestamp Difference ' num2str(i) ': ' num2str(timeDifference*daqfix)]);
    else
        disp(['Data Group ' num2str(i) ': Less than two peaks detected in the filtered voltage signal.']);
    end
end

% Calculate and display the mean value of the time differences
meanTimeDifference = mean(timeDifferences);
disp(['Mean Time Difference: ' num2str(meanTimeDifference*daqfix)]);