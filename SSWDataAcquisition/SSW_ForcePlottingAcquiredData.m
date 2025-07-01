folder_path = 'C:\Users\pablo\Desktop\InvestigacionUSFQ\SSWCompleteAnalysis\SingleSolitaryWaveAnalysis\ResultadosBolazosSSW_TOF\ResultadosBolazosProctorsPabloMajo2';
close all;
daqfix = 1; 
file_name = 'M5_25_Est_ConPlaca';
threshold = 0.00005;

file_path = fullfile(folder_path, file_name);
load(file_path);

% Calibration data from sheet
input_LBF = [20, 40, 60, 80, 100];
output_mV = [990, 1984, 2978, 3971, 4972];

% Compute calibration constants (linear fit)
a_LBF = (input_LBF(end) - input_LBF(1)) / (output_mV(end) - output_mV(1)); % Slope in LBF/mV
b_LBF = input_LBF(1) - a_LBF * output_mV(1); % Offset in LBF

% Convert to Newtons (1 LBF = 4.44822 N)
a_N = a_LBF * 4.44822;
b_N = b_LBF * 4.44822;

% Select the first dataset
data = scanData{1};
time = data(:, 1);  % Assuming time is in the first column
sensor_output_mV = data(:, 2)*1000;  % Assuming sensor output is in the second column

% Convert sensor output to force in Newtons
force_N = a_N * sensor_output_mV + b_N;

% Find the max force
max_force = max(force_N);
disp(['Maximum Force Measured: ', num2str(max_force), ' N']);

% Plot the force over time
figure;
plot(time, force_N, 'b', 'LineWidth', 1.5);
xlabel('Time (s)');
ylabel('Force (N)');
title('Force vs Time from Sensor Data');
grid on;

% Time difference calculation between peaks
filteredForce = force_N;
filteredForce(force_N < threshold) = 0; % Remove small peaks

[peaks, peakIndices] = findpeaks(filteredForce);
peakTime = time(peakIndices);

if numel(peaks) >= 2
    % Find two highest peaks
    [sortedPeaks, sortedIndices] = sort(peaks, 'descend');
    highestPeaks = sortedPeaks(1:2);
    highestPeakTimes = peakTime(sortedIndices(1:2));

    % Calculate time difference
    timeDifference = abs(diff(highestPeakTimes));
    disp(['Time Difference Between Peaks: ', num2str(timeDifference * daqfix), ' s']);

    % Mark peaks in the plot
    hold on;
    scatter(highestPeakTimes, highestPeaks, 'ro', 'MarkerFaceColor', 'r');
else
    disp('Less than two peaks detected in the filtered force signal.');
end

% Save Data to Excel
output_filename = 'SSW_Measumerent_mV_To_Force(N).xlsx';

% Create a table for export
T = table(time, sensor_output_mV, force_N, 'VariableNames', {'Time_s', 'Sensor_Output_mV', 'Force_N'});

% Save time, sensor output, and force to Excel
writetable(T, output_filename, 'Sheet', 'RawData');

% Save peak forces and times separately
if numel(peaks) >= 2
    peak_data = table(highestPeakTimes, highestPeaks, 'VariableNames', {'Peak_Time_s', 'Peak_Force_N'});
    writetable(peak_data, output_filename, 'Sheet', 'PeakData');
end

% Save summary (max force and time between peaks)
summary_data = table(max_force, timeDifference * daqfix, 'VariableNames', {'Max_Force_N', 'Time_Between_Peaks_s'});
writetable(summary_data, output_filename, 'Sheet', 'Summary');

disp(['Data saved to ', output_filename]);