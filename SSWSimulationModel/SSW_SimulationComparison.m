clear all; close all;
% Load the saved data from the MAT file
load(['C:\Users\pablo\Desktop\InvestigacionUSFQ\SSWCompleteAnalysis\SingleSolitaryWaveAnalysis\' ...
    'SSWSimulationModel\Numerical_Saw_Bones_Data\PCF_445.00_num_data_poi0.10_v00.22.mat']);
load('C:\Users\pablo\Desktop\InvestigacionUSFQ\SSWCompleteAnalysis\CallibrationSSWSawBones\PCF30_#1_PLA_Plate.mat');

folderName = 'SSW_Saw_Bones_Callibration_Data';
filename_exp = 'PCF_30_exp_data.xlsxwqw';
filename_num = 'PCF_30_num_data.xlsxwqw';
tittle = 'PCF30';
disp(length(scanData))

save_files = false;
data = scanData{4};


down = 9;
top = 300000;
top_2 = 130;

xdata = data(:, 1);
ydata = data(:, 2);

xdata = xdata(1:top_2);
ydata = ydata(1:top_2);

FA91 = real(FA91(down:top));
nonZeroIndices = FA91 ~= 0;
FA91 = FA91(nonZeroIndices);
t = t(nonZeroIndices);

% Find the indices of the two highest peaks in the scan data
[~, peak_indices_scan] = findpeaks(ydata, 'SortStr', 'descend', 'NPeaks', 2);

% Find the indices of the two highest peaks in the impact data
[~, peak_indices_impact] = findpeaks(abs(FA91), 'SortStr', 'descend', 'NPeaks', 2);

% Calculate the x-axis shift to align the highest peak with the y-axis for both curves
x_shift_scan = xdata(peak_indices_scan(1));
x_shift_impact = t(peak_indices_impact(2));

right_shift = 0.000001;

% Shift the x values of both curves
xdata_shifted_scan = xdata - x_shift_scan + right_shift;
t_shifted_impact = t - x_shift_impact + right_shift;

% Extract data around the peak indices
extracted_ydata_scan = ydata(peak_indices_scan);
extracted_xdata_scan = xdata_shifted_scan(peak_indices_scan);
extracted_ydata_impact = FA91(peak_indices_impact);
extracted_xdata_impact = t_shifted_impact(peak_indices_impact);

% Normalize the impact data by dividing all y-values by the maximum value
maxForce = max(FA91);
normalizedFA91 = FA91 / maxForce;

% Normalize the scan data by dividing all y-values by the maximum value
maxScanData = max(ydata);
normalizedScanData = ydata / maxScanData;

% Determine the maximum x-value in the shifted scan data
maxX = max(t_shifted_impact);


% Create a figure for the normalized impact graph and the normalized scan data
figure;
set(gcf, 'Position', [100, 100, 800, 600]);  % Adjust the figure size
hold on;

% Plot the normalized impact data with blue color, solid line, and markers every 1000 points
marker_interval = 15000;
marker_indices = 500:marker_interval:numel(t_shifted_impact);
marker_indices = [1:10:500 marker_indices];
plot(t_shifted_impact, normalizedFA91, 'b:', 'LineWidth', 1.5, 'DisplayName', 'Impact Data', 'Marker', 'x', 'MarkerIndices', marker_indices, 'MarkerFaceColor', 'b');

% Plot the normalized scan data with red color, solid line, and markers every 1000 points
marker_interval = 10;
marker_indices = 1:marker_interval:numel(xdata_shifted_scan);
plot(xdata_shifted_scan, normalizedScanData, 'r-', 'LineWidth', 1.5, 'DisplayName', 'Scan Data', 'Marker', 'x', 'MarkerIndices', marker_indices, 'MarkerFaceColor', 'r');

hold off;
title(tittle)
xlabel('Time (s)');
ylabel('Normalized Force');
legend( 'Numerical','Experimental')
grid on;  % Enable grid lines

% Create a folder named 'SSW_Saw_Bones_Callibration_Data'

if ~exist(folderName, 'dir')
    mkdir(folderName);
end

% t_shifted_impact, normalizedFA91,

% Save the relevant data to a file inside the folder
filePath = fullfile(folderName, filename_exp);
if save_files
    writematrix([xdata_shifted_scan, normalizedScanData], filePath);
end

filePath = fullfile(folderName, filename_num);
if save_files
    writematrix([t_shifted_impact, normalizedFA91], filePath);
end
% Calculate and save TOF for experimental data
timeDifference_exp = calculateTOF(xdata, ydata, 'Experimental');

% Calculate and save TOF for numerical data
timeDifference_num = calculateTOF(t, FA91, 'Numerical');


function timeDifference = calculateTOF(xdata, ydata, dataType)
    threshold = 0.00005;
    timeDifference = [];  % Initialize an empty array to store the time differences

    % Filter the data by applying a threshold to remove small peaks
    filteredYData = ydata;
    % filteredYData(ydata < threshold) = 0;

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

        % Append the time difference to the array
        disp(['Timestamp Difference ' dataType ': ' num2str(timeDifference)]);
    else
        disp(['Data Group ' dataType ': Less than two peaks detected in the filtered data.']);
    end
end