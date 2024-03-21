clear all;
% Load the saved data from the MAT file
load('Hueso_PCF5_Simulation_Con_placa.mat');
load('C:\Users\pablo\Desktop\InvestigacionUSFQ\SSWCompleteAnalysis\CallibrationSSWSawBones\PCF05_#1_PLA_Plate.mat');

data = scanData{2};
xdata = data(:, 1);
ydata = data(:, 2);

% Find the indices of the two highest peaks in the scan data
[~, peak_indices_scan] = findpeaks(ydata, 'SortStr', 'descend', 'NPeaks', 2);

% Find the indices of the two highest peaks in the impact data
[~, peak_indices_impact] = findpeaks(abs(FA91), 'SortStr', 'descend', 'NPeaks', 2);

% Normalize the impact data by dividing all y-values by the maximum value
maxForce = max(FA91);
normalizedFA91 = FA91 / maxForce;

% Normalize the scan data by dividing all y-values by the maximum value
maxScanData = max(ydata);
normalizedScanData = ydata / maxScanData;

downsampleFactor = 10;
downsampledFA91 = downsample(normalizedFA91, downsampleFactor);

downsampledTime = downsample(t, downsampleFactor);



figure
plot(downsampledTime, downsampledFA91)
