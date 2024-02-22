% Load the data from the file
load('TOF.mat', 'TOF_data');

% Poisson's ratio values used in the simulation
pois = [0.1,0.2, 0.3, 0.4, 0.5];

% Young's modulus values used in the simulation
mody = [5e6, 25e6, 50e6, 100e6, 200e6, 300e6, 400e6];

% Create figure to plot data
figure;

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
    
    % Plot TOF values for this Poisson's ratio with lines connecting the points
    plot(tof_values_combined, mody, '-o', 'DisplayName', sprintf('Poisson: %.1f', poi1));
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

% Show legend for the entire plot
legend('Location', 'best');

% % Create "Validate" button
% validate_button = uicontrol('Style', 'pushbutton', ...
%                             'String', 'Validate', ...
%                             'Position', [20, 10, 80, 30], ...
%                             'Callback', @validateButtonCallback);
% 
% % Create "New Test" button
% new_test_button = uicontrol('Style', 'pushbutton', ...
%                             'String', 'New Test', ...
%                             'Position', [120, 10, 80, 30], ...
%                             'Callback', {@newTestButtonCallback, pois, mody, TOF_data}); % Pass 'pois' and 'mody' as arguments

% Callback function for the "Validate" button
function validateButtonCallback(~, ~)
    % Arrays to store the inserted points
    inserted_x = [];
    inserted_y = [];
    
    while true
        % Get input from the user
        input_str = inputdlg('Enter X and Y coordinates (or "stop" to finish):', 'Insert Point');
        
        % Check if the user wants to stop inserting points
        if isempty(input_str) || strcmpi(input_str{1}, 'stop')
            break;
        end
        
        % Convert the input string to numeric values
        xy = str2num(input_str{1});
        
        % Check if the input is valid (contains two values)
        if numel(xy) == 2
            x = xy(1);
            y = xy(2);
            
            % Plot the inserted point with larger red marker
            hold on;
            plot(x, y, 'ro', 'MarkerSize', 10, 'DisplayName', 'Inserted Points');
            
            % Store the inserted point in the arrays
            inserted_x = [inserted_x, x];
            inserted_y = [inserted_y, y];
            
            % Display the inserted point in a more readable format
            fprintf('Inserted point: X = %.6f, Y = %.1e\n', x, y);
        else
            disp('Invalid input. Please enter two numeric values (X Y) or "stop" to finish.');
        end
    end
    
    % Update the legend to include the inserted points
    legend('Location', 'best');
end

% Callback function for the "New Test" button
function newTestButtonCallback(~, ~, pois, mody, TOF_data)
    % Get input from the user for TOF and Poisson's ratio
    input_str = inputdlg({'Enter TOF value:', 'Enter Poisson''s ratio:'}, 'New Test');
    if isempty(input_str)
        return;
    end
    
    % Convert the input strings to numeric values
    tof_value = str2double(input_str{1});
    poisson_ratio = str2double(input_str{2});
    
    % Find the closest Poisson's ratio in the provided array 'pois'
    [~, idx] = min(abs(pois - poisson_ratio));
    closest_poisson = pois(idx);
    
    % Extract TOF values and corresponding Young's modulus values for the selected Poisson's ratio
    tof_values = TOF_data{idx, :};
    modulus_values = mody; % Since mody is a vector, no need to index it
    
    % Interpolate the Young's modulus using the provided TOF value
    estimated_modulus = interp1(tof_values, modulus_values, tof_value, 'linear');
    
    % Display the interpolated modulus value to the console
    fprintf('Interpolated Modulus for TOF = %.6f and Closest Poisson''s ratio %.2f: %.1e Pa\n', tof_value, closest_poisson, estimated_modulus);
    
    % Plot the new point and the interpolation
    hold on;
    plot(tof_value, estimated_modulus, 'bs', 'MarkerSize', 10, 'DisplayName', 'New Test Point');
    
    % Add the interpolation line
    plot(tof_values, modulus_values, 'k--', 'DisplayName', 'Interpolation');
    
    % Update the legend to include the new point and interpolation
    legend('Location', 'best');
end

