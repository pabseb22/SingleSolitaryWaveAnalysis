% Define the directory where you want to save the figures
save_dir = 'C:\Users\pablo\Desktop';

% Original code to calculate and plot mean time differences
folder_path = 'C:\Users\pablo\Desktop\InvestigacionUSFQ\SSWCompleteAnalysis\ResultadosBolazosSSW_TOF\Cuadricula2LaCeramica';
daqfix = 1;
threshold = 0.0005;

close all;

% Get a list of all files in the folder with the naming pattern 'M_*_*'
files = dir(fullfile(folder_path, 'M_*_*'));

% Initialize arrays to store mean time differences and corresponding positions
meanTimeDifferences = zeros(4, 4);
positions = zeros(4, 4);

for fileIndex = 1:length(files)
    file_name = files(fileIndex).name;
    file_path = fullfile(folder_path, file_name);
    
    % Load data from the current file
    load(file_path);

    timeDifferences = [];  % Initialize an empty array to store the time differences

    for i = 1:numel(scanData)
        data = scanData{i};
        xdata = data(:, 1); % Assuming the first column contains the x-values
        ydata = data(:, 2); % Assuming the second column contains the y-values
        filteredYData = ydata;
        filteredYData(ydata < threshold) = 0;

        [peaks, peakIndices] = findpeaks(filteredYData);
        peakXData = xdata(peakIndices);

        if numel(peaks) >= 2
            [sortedPeaks, sortedIndices] = sort(peaks, 'descend');
            highestPeaks = sortedPeaks(1:2);
            highestPeakIndices = peakIndices(sortedIndices(1:2));
            highestPeakXData = peakXData(sortedIndices(1:2));

            timeDifference = abs(diff(highestPeakXData));
            timeDifferences = [timeDifferences; timeDifference];
        else
            disp(['Data Group ' num2str(i) ': Less than two peaks detected in the filtered voltage signal.']);
        end
    end

    % Calculate and store the mean value of the time differences for the current file
    meanTimeDifference = mean(timeDifferences);
    
    % Extract row and column indices from the file name
    indices = sscanf(file_name, 'M_%d_%d');
    row = indices(1);
    col = indices(2);
    
    % Store mean time difference and position in arrays
    meanTimeDifferences(row, col) = meanTimeDifference;
    positions(row, col) = fileIndex;
    
    disp(['Mean Time Difference for ' file_name ': ' num2str(meanTimeDifference * daqfix)]);
end

% Define the threshold value
threshold_value = 0.00155809;

% Create a custom colormap for the heatmap
custom_colormap = zeros(2, 3); % Initialize a 2x3 matrix for RGB values
custom_colormap(1, :) = [0.8, 1, 0.8]; % Light green for values <= threshold
custom_colormap(2, :) = [1, 0.8, 0.8]; % Light red for values > threshold

% Create a binary matrix based on the threshold
binaryMatrix = meanTimeDifferences > threshold_value;

% Create the heatmap-like visualization using imagesc
figure;
imagesc(binaryMatrix);
colormap(custom_colormap);
caxis([0 1]);
colorbar('off'); % Disable the colorbar
title('Bottom Layer', 'FontName', 'Times New Roman', 'FontSize', 8);


% Add text annotations with mean time difference values
for row = 1:4
    for col = 1:4
        value = meanTimeDifferences(row, col);
        text(col, row, sprintf('%.5f', value), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'Color', 'k', 'FontSize', 8, 'FontName', 'Times New Roman');
    end
end

% Set the axis tick labels font properties
ax = gca;
ax.FontName = 'Times New Roman';
ax.FontSize = 8;

% Set X and Y axis ticks to show only whole numbers
ax.XTick = 1:4;
ax.YTick = 1:4;

% Adjust the figure size to 9cm x 9cm and save as PNG
set(gcf, 'PaperUnits', 'centimeters');
set(gcf, 'PaperPosition', [0 0 9 6]); % [left, bottom, width, height]
print(gcf, fullfile(save_dir, 'CuadriculaInferior.png'), '-dpng', '-r900'); % Save at 300 DPI
