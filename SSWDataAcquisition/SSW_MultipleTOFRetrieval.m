%% Setup
close all; clearvars;

%% Parameters
folder_path = 'SingleSolitaryWaveAnalysis/Pastas_Mortero_2025/0p40';
threshold = 0.002;
minPeakDistance = 0.0001; % Minimum distance between peaks in seconds (adjust as needed)

files = dir(fullfile(folder_path, '*.mat'));

% Tabla de resultados (solo Top 3 en Excel + TOFs + F1/F2)
resultsTable = table('Size', [0 12], ...
    'VariableTypes', {'string','double', ...                   % Filename, Group
                      'double','double','double','double', ... % Pico1_X, Pico1_Y, Pico2_X, Pico2_Y
                      'double','double','double','double', ... % Pico3_X, Pico3_Y, TOF1, TOF2
                      'double','double'}, ...                  % F1, F2
    'VariableNames', {'Filename','Group', ...
                      'Pico1_X','Pico1_Y','Pico2_X','Pico2_Y', ...
                      'Pico3_X','Pico3_Y','TOF1','TOF2', ...
                      'F1','F2'});

%% Main Processing Loop
for fileIdx = 1:length(files)
    file_name = files(fileIdx).name;
    file_path = fullfile(folder_path, file_name);

    load(file_path);
    fprintf('\n========== Processing file: %s ==========\n', file_name);

    for groupIdx = 1:numel(scanData)
        data  = scanData{groupIdx};
        xdata = data(:,1); % Time
        ydata = data(:,2); % Amplitude

        % Filtrado simple por umbral
        filteredYData = ydata;
        filteredYData(ydata < threshold) = 0;

        % Detectar picos
        [peaks, peakXData] = findpeaks(filteredYData, xdata, ...
                                       'MinPeakDistance', minPeakDistance);

        if isempty(peaks)
            fprintf('  Group %d: No peaks detected.\n', groupIdx);
            continue;
        end

        % ---- Top 5 peaks (para graficar) ----
        [~, sortedIdx] = sort(peaks, 'descend');
        topN = min(5, numel(peaks));
        topIdx = sortedIdx(1:topN);

        % Ordenados por tiempo
        [topTimesSorted, orderT] = sort(peakXData(topIdx));
        topValsSorted = peaks(topIdx(orderT));

        % Imprimir Top 5
        fprintf('\n# TOP_%d_PEAKS\t%s\tGroup\t%d\n', topN, file_name, groupIdx);
        fprintf('Rank\tX\tY\n');
        for r = 1:topN
            fprintf('%d\t%.10f\t%.10f\n', r, topTimesSorted(r), topValsSorted(r));
        end

        % ---- Para Excel: solo primeros 3 picos por tiempo ----
        saveN = min(3, numel(topTimesSorted));
        picoX = nan(1,3); picoY = nan(1,3);
        picoX(1:saveN) = topTimesSorted(1:saveN);
        picoY(1:saveN) = topValsSorted(1:saveN);

        % Calcular TOFs (solo entre 1-2 y 2-3)
        TOF1 = NaN; TOF2 = NaN;
        if saveN >= 2
            TOF1 = picoX(2) - picoX(1);
        end
        if saveN >= 3
            TOF2 = picoX(3) - picoX(2);
        end

        % Calcular F1 = y2/y1 y F2 = y3/y1
        F1 = NaN; F2 = NaN;
        if saveN >= 2 && picoY(1) ~= 0
            F1 = picoY(2) / picoY(1);
        end
        if saveN >= 3 && picoY(2) ~= 0
            F2 = picoY(3) / picoY(1);
        end

        % Guardar en tabla
        resultsTable = [resultsTable; {file_name, groupIdx, ...
            picoX(1), picoY(1), picoX(2), picoY(2), ...
            picoX(3), picoY(3), TOF1, TOF2, F1, F2}];

        % ---- Plot con Top 5 ----
        fig = figure('Name', sprintf('%s - Group %d', file_name, groupIdx));
        plot(xdata, ydata, '-','LineWidth',1.2); hold on; grid on;
        plot(topTimesSorted, topValsSorted, 'sr', 'MarkerSize', 9, 'LineWidth', 1.8);
        for r = 1:topN
            text(topTimesSorted(r), topValsSorted(r), sprintf('  #%d', r), ...
                'FontWeight','bold','VerticalAlignment','bottom','Clipping','on');
        end
        xlabel('Time (s)');
        ylabel('Amplitude');
        title(sprintf('Top %d Peaks - %s - Group %d', topN, file_name, groupIdx));
        legend({'Signal','Top Peaks'}, 'Location','best');

        waitfor(fig);
    end

    % Fila separadora
    resultsTable = [resultsTable; {'---', NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN}];
end

%% Save Excel
% excel_filename = fullfile(folder_path, 'secondary_TOF_results.xlsx');
% writetable(resultsTable, excel_filename);
% fprintf('\nTop 3 peaks (with F1,F2) saved to: %s\n', excel_filename);
