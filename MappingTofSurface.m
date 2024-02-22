folder_path = 'C:\Users\pablo\Desktop\InvestigacionUSFQ\SSWCompleteAnalysis\ResultadosBolazos\Cuadricula2LaCeramica';
daqfix = 1;
threshold = 0.005;

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

% Create a heatmap-like visualization using imagesc with 'parula' colormap
figure;
imagesc(meanTimeDifferences);
colormap(parula);
colorbar;
title('Cuadricula Inferior');
xlabel('Column');
ylabel('Row');

% Add text annotations with mean time difference values
for row = 1:4
    for col = 1:4
        value = meanTimeDifferences(row, col);
        text(col, row, sprintf('%.5f', value), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'Color', 'k', 'FontWeight', 'bold');
    end
end
