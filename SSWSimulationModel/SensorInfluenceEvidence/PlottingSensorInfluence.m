% Define file names
files = {"RegularRun_100MPa.mat", "SphereContactEquation_Sensor_100MPa.mat", ...
         "DoubleStiffnessSensor_100MPa.mat", "HalfStiffnessSensor_100MPa.mat"};

names = {"Regular Run", "Sphere Contact", "Double Stiffness", "Half Stiffness"};

% Define colors for each line (visually distinct)
colors = lines(length(files)); % MATLAB's default color palette

% Create figure
figure;
hold on;

% Set font properties
set(gca, 'FontName', 'Times New Roman', 'FontSize', 14, 'LineWidth', 1.5);

% Initialize TOFM storage
all_TOF = [];

% Loop through each file and plot data
for i = 1:length(files)
    % Load data
    data = load(files{i});
    
    % Extract variables (assuming 't' and 'FA91' exist in the files)
    t = data.t;
    FA91 = real(data.FA91); % Ensure only real values are used
    
    % Filter data to limit peak search to t <= 0.000156
    valid_idx = t <= 0.0019;
    t_filtered = t(valid_idx);
    FA91_filtered = FA91(valid_idx);
    
    % Plot with a unique color and line style
    plot(t_filtered, FA91_filtered, 'LineWidth', 1.1, 'Color', colors(i, :), 'DisplayName', names{i});

    % Compute TOF
    [pks, locs] = findpeaks(FA91_filtered, t_filtered, 'MinPeakHeight', 70);

    % Ensure there are at least two peaks before calculating TOF
    if length(locs) >= 2
        TOFM = locs(2) - locs(1);
    else
        TOFM = NaN; % Assign NaN if not enough peaks are found
    end

    % Store TOFM
    all_TOF = [all_TOF; {names{i}, TOFM}];

    % Print TOF values for each iteration
    fprintf('Iteration %d: TOF = %.10f\n', i, TOFM);
end

% Labels and legend
xlabel('Time (s)', 'FontName', 'Times New Roman', 'FontSize', 16);
ylabel('Force (N)', 'FontName', 'Times New Roman', 'FontSize', 16);
title('100MPa', 'FontName', 'Times New Roman', 'FontSize', 16);

ylim([0, 300]); 
legend('Location', 'north', 'Interpreter', 'none');

% Save as high-resolution TIFF
set(gcf, 'PaperPositionMode', 'auto'); % Auto-size for saving
print('100MPa', '-dtiff', '-r1200'); % Saves at 1200 DPI

% Show message
disp('Plot saved as 100MPa.tiff with high resolution.');

% Save TOF results to Excel
TOF_table = cell2table(all_TOF, 'VariableNames', {'Dataset', 'TOF (s)'});
writetable(TOF_table, '100MPa_TOF_Measurements.xlsx');

disp('TOF data saved to 100MPa_TOF_Measurements.xlsx.');
