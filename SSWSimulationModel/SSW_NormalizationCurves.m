clear all;
% Load the saved data from the MAT file
load('C:\Users\pablo\Desktop\InvestigacionUSFQ\SSWCompleteAnalysis\SingleSolitaryWaveAnalysis\ResultadosBolazosSSW_TOF\CallibrationSSWSawBones_TOF_Data\PCF30_#1_PLA_Plate.mat');
load('C:\Users\pablo\Desktop\InvestigacionUSFQ\SSWCompleteAnalysis\SingleSolitaryWaveAnalysis\SSWSimulationModel\Numerical_Saw_Bones_Data\PCF_445.00_num_data_poi0.30_v00.26.mat');

data = scanData{1};
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

downsampleFactor = 50;
downsampledFA91 = downsample(normalizedFA91, downsampleFactor);

downsampledTime = downsample(t, downsampleFactor);



figure
plot(downsampledTime, downsampledFA91)
