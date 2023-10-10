% Load the data from the file
load('TOFvsYoungAnalysisWithPlate.mat', 'TOF_data');

% Poisson's ratio values used in the simulation
pois = [0.1, 0.3, 0.5];

% Young's modulus values used in the simulation
mody = [50e6, 100e6, 200e6, 300e6];

% Create a figure with larger size
figure('Position', [100, 100, 800, 600]);

% Iterate over Poisson's ratio values
for k = 1:length(pois)
    poi1 = pois(k);
    
    % Collect the data points for each Poisson's ratio
    tof_values_combined = [];
    
    % Iterate over Young's modulus values and plot TOF data for each Poisson's ratio
    for j = 1:length(mody)
        Ew = mody(j);
        tof_values = TOF_data{k, j}; % Extract TOF values for specific poi1 and Ew
        
        % Collect TOF values for each Young's modulus
        tof_values_combined = [tof_values_combined; tof_values']; % Use semicolon to concatenate vertically
    end
    
    % Plot TOF values for this Poisson's ratio with lines and no markers
    plot(tof_values_combined, mody, 'LineWidth', 2, 'DisplayName', sprintf('Poisson: %.1f', poi1));
    hold on;
end

% Set plot labels and title
xlabel('TOF (s)');
ylabel('Young''s Modulus (Pa)');
title('Calibration Curve - With Plate');

% Set the y-axis to a logarithmic scale
set(gca, 'YScale', 'log');

% Add more divisions to the y-axis (optional)
yticks([1e6 2e6 5e6 1e7 2e7 5e7 1e8 2e8 5e8 1e9]);

% Display Y-axis labels in scientific notation with the exponent
ytickformat('%.1e');

% Show grid lines to aid in reading values (optional)
grid on;

% Customize line styles
ax = gca;
ax.ColorOrderIndex = 1;  % Reset color order
lines = findobj(gcf, 'Type', 'Line');
for i = 1:length(lines)
    set(lines(i), 'LineStyle', ':');
end

% Show legend for the entire plot
legend('Location', 'best');


% Set the y-axis limits to start from zero
ylim([0, max(mody)+ 1e6]);
xlim([0.0015, max(tof_values_combined)+0.00005])
