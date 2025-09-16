% Define the directory where you want to save the figures
save_dir = 'C:\Users\pablo\Desktop';

% Original code to calculate and plot mean time differences
folder_path = 'C:\Users\pablo\Desktop\InvestigacionUSFQ\SSWCompleteAnalysis\ResultadosBolazos\CuadriculaIntermedia';
daqfix = 1;
threshold = 0.0005;

close all;

% Get a list of all files in the folder with the naming pattern 'M_*_*'
files = dir(fullfile(folder_path, 'MI_*_*'));

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
    indices = sscanf(file_name, 'MI_%d_%d');
    row = indices(1);
    col = indices(2);
    
    % Store mean time difference and position in arrays
    meanTimeDifferences(row, col) = meanTimeDifference;
    positions(row, col) = fileIndex;
    
    disp(['Mean Time Difference for ' file_name ': ' num2str(meanTimeDifference * daqfix)]);
end

% Define the base color
base_color = [192, 0, 0] / 255;  % Convert RGB to [0, 1] range

% Create a gradient colormap from white to the base color
num_colors = 100; % Number of colors in the colormap
colormap_custom = [linspace(1, base_color(1), num_colors)', ...
                   linspace(1, base_color(2), num_colors)', ...
                   linspace(1, base_color(3), num_colors)'];

% Create the "sky" colormap
% Create a heatmap-like visualization using imagesc with 'parula' colormap
figure;
imagesc(meanTimeDifferences);
colormap(colormap_custom);
colorbar;
clim([0.001 0.0020]);
title('Middle Layer', 'FontName', 'Times New Roman', 'FontSize', 8);

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
print(gcf, fullfile(save_dir, 'CuadriculaIntermedia.png'), '-dpng', '-r900'); % Save at 300 DPI

% New code to create the density heatmap
% Reshape the density array into a 4x4 matrix
density = [
1.719206353	1.584155443	1.681393835	1.698312575;
1.738761829	1.624408437	1.655708519	1.715820696;
1.680350877	1.701151368	1.593159483	1.735227626;
1.675895509	1.705817017	1.555102102	1.72366369;

];

% Create a new figure for the density heatmap
figure;
imagesc(density);
colormap('sky');
h = colorbar;
% Add units label to the colorbar
ylabel(h, 'g/cm^3', 'FontName', 'Times New Roman', 'FontSize', 8);
% Adjust the color limits if necessary
% clim([min(density(:)), max(density(:))]);
title('Dry Density Distribution', 'FontName', 'Times New Roman', 'FontSize', 8);

% Add text annotations with density values
for row = 1:4
    for col = 1:4
        value = density(row, col);
        text(col, row, sprintf('%.3f', value), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'Color', 'k', 'FontSize', 8, 'FontName', 'Times New Roman');
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
print(gcf, fullfile(save_dir, 'Dry_Density_Distribution.png'), '-dpng', '-r300'); % Save at 300 DPI