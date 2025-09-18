%% Setup
close all; clear all;

%% Parameters
folder_path = 'SingleSolitaryWaveAnalysis\Pastas_Mortero_2025\0p30';
threshold = 0.00002;
minPeakDistance = 0.0001; % Minimum distance between peaks in seconds (adjust as needed)

files = dir(fullfile(folder_path, '*.mat'));

% Inicializar tabla de resultados
resultsTable = table('Size', [0 10], ...
    'VariableTypes', {'string','double','double','double','double','double','double','double','double','double'}, ...
    'VariableNames', {'Filename','Group','Pico1_X','Pico1_Y','Pico2_X','Pico2_Y','Pico3_X','Pico3_Y','TOF1','TOF2'});

%% Main Processing Loop
for fileIdx = 1:length(files)
    file_name = files(fileIdx).name;
    file_path = fullfile(folder_path, file_name);

    load(file_path);
    fprintf('\nProcessing file: %s\n', file_name);

    for groupIdx = 1:numel(scanData)
        data = scanData{groupIdx};
        xdata = data(:,1); % Time
        ydata = data(:,2); % Amplitude

        % Filter noise
        filteredYData = ydata;
        filteredYData(ydata < threshold) = 0;

        % Detect peaks with minimum distance in seconds
        [peaks, peakXData] = findpeaks(filteredYData, xdata, 'MinPeakDistance', minPeakDistance);
        
        if numel(peaks) >= 3
            [~, sortedIndices] = sort(peaks, 'descend');
            topIndices = sortedIndices(1:3);
        
            % Sort by time
            [peakTimes, order] = sort(peakXData(topIndices));
            peakValues = peaks(topIndices(order));
        
            % TOFs
            tof1 = peakTimes(2) - peakTimes(1);
            tof2 = peakTimes(3) - peakTimes(2);

            % Save in table
            resultsTable = [resultsTable; {file_name, groupIdx, ...
                peakTimes(1), peakValues(1), ...
                peakTimes(2), peakValues(2), ...
                peakTimes(3), peakValues(3), ...
                tof1, tof2}];

            % Plot only for the second group
            %if groupIdx == 2
                fig = figure('Name', sprintf('%s - Group %d', file_name, groupIdx));
                plot(xdata, ydata, '-b'); hold on;
                plot(peakTimes, peakValues, 'or', 'MarkerSize', 8, 'LineWidth', 1.5);
                xlabel('Time (s)');
                ylabel('Amplitude');
                title(sprintf('Detected Peaks - %s - Group %d', file_name, groupIdx));
                legend('Signal','Detected Peaks');
                grid on;

                % Wait until figure is closed before continuing
                waitfor(fig);
            %end
        else
            fprintf('  Group %d: Less than three peaks detected.\n', groupIdx);
        end
    end

    % Add separator row
    resultsTable = [resultsTable; {'---', NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN}];
end


%% Guardar resultados en Excel
excel_filename = fullfile(folder_path, 'secondary_TOF_results.xlsx');
writetable(resultsTable, excel_filename);
fprintf('\nAll time differences saved to: %s\n', excel_filename);
