% Load the saved data from the MAT file
load('Hueso_PCF40_Simulation_Con_placa.mat');
load('../MatLab Scripts/Pelotazo/Hueso_PCF40_Pelotazo_Con_Placa_.mat');

data = scanData{2};
xdata = data(:, 1);
ydata = data(:, 2);

% Find the indices of the two highest peaks in the scan data
[~, peak_indices_scan] = findpeaks(ydata, 'SortStr', 'descend', 'NPeaks', 2);

% Find the indices of the two highest peaks in the impact data
[~, peak_indices_impact] = findpeaks(abs(FA91), 'SortStr', 'descend', 'NPeaks', 4);

% Calculate the x-axis shift to align the highest peak with the y-axis for both curves
x_shift_scan = xdata(peak_indices_scan(1));
x_shift_impact = t(peak_indices_impact(2));

right_shift = 0.0001;

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

title('PCF40 with Plate');
xlabel('Time (s)');
ylabel('Normalized Force');
legend("Simulation PCF40", "Experimental PCF40")
legend('Location', 'southwest');  % Adjust the legend location
grid on;  % Enable grid lines

% Set the x-axis limits from 0 to the maximum x-value
xlim([0, maxX]);
