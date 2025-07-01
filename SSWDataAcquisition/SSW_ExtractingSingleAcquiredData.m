folder_path = 'C:\Users\pablo\Desktop\InvestigacionUSFQ\SSWCompleteAnalysis\SingleSolitaryWaveAnalysis\ResultadosBolazosSSW_TOF\ResultadosBolazosProctorsPabloMajo2';
file_name = 'M6_25_Est_SinPlaca';
threshold = 0.00005;

file_path = fullfile(folder_path, file_name);
load(file_path);

% Extract scanData{2}
if length(scanData) < 2
    error('scanData{2} does not exist. Make sure your dataset contains at least two elements.');
end

data = scanData{1};
xdata = data(:, 1); % X values
ydata = data(:, 2); % Y values (force signal)

% Plot data
figure;
plot(xdata, ydata, 'b-', 'LineWidth', 1.2);
xlabel('Time (s)', 'FontName', 'Times New Roman', 'FontSize', 14);
ylabel('Force (N)', 'FontName', 'Times New Roman', 'FontSize', 14);
title('ScanData{2}', 'FontName', 'Times New Roman', 'FontSize', 14);
grid on; hold on;

% Apply threshold to filter noise
filteredYData = ydata;
filteredYData(ydata < threshold) = 0;

% Find peaks
[peaks, peakIndices] = findpeaks(filteredYData);
peakXData = xdata(peakIndices);

% Compute TOF (Time of Flight)
if numel(peaks) >= 2
    [sortedPeaks, sortedIndices] = sort(peaks, 'descend');
    highestPeaks = sortedPeaks(1:2);
    highestPeakXData = peakXData(sortedIndices(1:2));

    % TOF calculation
    TOF = abs(diff(highestPeakXData));
    
    % Mark peaks on plot
    scatter(highestPeakXData, highestPeaks, 'ro', 'MarkerFaceColor', 'r');
    
    disp(['TOF (s): ' num2str(TOF)]);
else
    TOF = NaN; % Not enough peaks
    disp('Less than two peaks detected, unable to calculate TOF.');
end

% Save results to Excel
output_table = table(xdata, ydata, repmat(TOF, size(xdata)), ...
    'VariableNames', {'Time (s)', 'Voltage', 'TOF (s)'});
output_filename = 'SueloCeramica_SinPlaca_Results.xlsx';
writetable(output_table, output_filename);

disp(['Data saved to ', output_filename]);
