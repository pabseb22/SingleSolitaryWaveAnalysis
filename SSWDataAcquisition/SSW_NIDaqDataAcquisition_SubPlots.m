global allData;
global allTimestamps;
global startIndex;
global endIndex;
global scanData;
global fileName;  % Define a global variable for the file name
global saveFolderPath;  % Define a global variable for the folder path

% Define the folder path where you want to save the file
saveFolderPath = 'ResultadosBolazosCaolinProbetas';  % Replace with the actual folder path

% Set the file name here
fileName = '(EstaSi)Masa#1_SinPlaca_Run#1.mat';


format long;

dq = daq("ni"); % Creates a data Acquisition
dq.Rate = 100000; % Defines Rate or number of Scans Made per Second
addinput(dq, "cDAQ1Mod1", "ai0", "Voltage"); %cDAQ1Mod1 Connects to First Device

% Set up the figure and axes for real-time plotting
fig = uifigure('Name', 'Real-Time Plot');
grid = uigridlayout(fig, [2, 1]);
grid.RowHeight = {'4x', '1x'}; % Adjust row heights

plotAxes = uiaxes(grid);
plotAxes.Layout.Row = 1;
plotAxes.Layout.Column = 1; % Adjust column span
plotAxes.Position = [40 40 560 350]; % Adjust position and size of the axes
hold(plotAxes, 'on');

buttonGrid = uigridlayout(grid, [1, 3]);
buttonGrid.Layout.Row = 2;

resetButton = uibutton(buttonGrid, 'push', 'Text', 'Reset');
resetButton.Layout.Column = 1;
resetButton.ButtonPushedFcn = @(src, event) resetButtonCallback(src, event, fig, plotAxes);


saveButton = uibutton(buttonGrid, 'push', 'Text', 'Save Scan');
saveButton.Layout.Column = 2;
saveButton.ButtonPushedFcn = @saveButtonCallback;

endButton = uibutton(buttonGrid, 'push', 'Text', 'End Test');
endButton.Layout.Column = 3;
endButton.ButtonPushedFcn = @endButtonCallback;

% Start the acquisition
start(dq);

startTime = tic; % Start the timer
elapsedTime = 0; % Initialize the elapsed time

% Initialize arrays to store the data
allData = [];
allTimestamps = [];

% SavedData
scanData = {};  % Initialize cell array to store scan groups

% Set up a loop to continuously update the plot and store the data
while true
    % Read the latest data
    [data, ~] = read(dq, 100000, "OutputFormat", "Matrix"); % Read data for 1 second (1000 scans)
    
    % Check if any data is available
    if ~isempty(data)
        % Store the data and timestamps
        allData = [allData; data];
        
        % Calculate the elapsed time for the current iteration
        elapsedTime = toc(startTime);
        
        % Create timestamps based on the elapsed time
        timestamps = linspace(elapsedTime - 1, elapsedTime, size(data, 1))';
        allTimestamps = [allTimestamps; timestamps];
        
        % Clear the plot
        if isvalid(fig) && isvalid(plotAxes)
            cla(plotAxes);
        end
        
        % Find the maximum value and its index
        [maxValue, maxIndex] = max(allData);
        
        % Calculate the start and end indices for the desired time range
        global startIndex;
        global endIndex;
        timeBefore = 0.0006; % 0.1 seconds before the maximum value
        timeAfter = 0.0032; % 0.2 seconds after the maximum value
        startIndex = max(1, maxIndex - round(timeBefore * dq.Rate));
        endIndex = min(maxIndex + round(timeAfter * dq.Rate), size(allTimestamps, 1));
        
        % Plot the data within the desired time range
        if isvalid(fig) && isvalid(plotAxes)
            plot(plotAxes, allTimestamps(startIndex:endIndex), allData(startIndex:endIndex));
            ylabel(plotAxes, "Voltage (V)");
            ylim(plotAxes, [min(allData), max(allData)+0.5]);

            % Adjust the x-axis limits dynamically
            xlim(plotAxes, [allTimestamps(startIndex), allTimestamps(endIndex)]);
        end
    end
    
    % Refresh the plot
    drawnow;
    
    % Check if the endButton is clicked
    if ~isvalid(fig) || ~isvalid(endButton)
        disp('Program ended');
        break; % Exit the loop
    end
end

% Callback function for "Reset" button
function resetButtonCallback(~, ~, fig, plotAxes)
    disp('Reset button clicked');
    
    % Clear the graph
    if isvalid(fig) && isvalid(plotAxes)
        cla(plotAxes);
    end
    
    % Clear the data
    global allData;
    global allTimestamps;
    allData = [];
    allTimestamps = [];
end

% Callback function for "Save Scan" button
function saveButtonCallback(~, ~)
    global allData;
    global allTimestamps;
    global startIndex;
    global endIndex;
    global scanData;
    
    % Check if data is available
    if ~isempty(allData) && ~isempty(allTimestamps)
        % Create a subarray with the data within the desired time range
        subArray = [allTimestamps(startIndex:endIndex), allData(startIndex:endIndex)];
        
        % Append the current scan group to scanData
        scanData{end+1} = subArray;

        disp('Save Scan button clicked');
    else
        disp('No data available to save.');
    end


end


% Callback function for "End Test" button
function endButtonCallback(~, ~)
    disp('End Test button clicked');
    global fileName;  % Define a global variable for the file name
    global saveFolderPath;  % Define a global variable for the folder path
    global scanData;
    % Combine the folder path and file name to create the full file path
    fullFilePath = fullfile(saveFolderPath, fileName);

    % Save the scanData to the specified folder and file
    save(fullFilePath, 'scanData');

    % Display the full file path for confirmation
    disp(['File saved at: ' fullFilePath]);
    
    delete(gcbf); % Close the figure to terminate the program

    timeDifferences = [];  % Initialize an empty array to store the time differences

    figure;  % Create a new figure

    for i = 1:numel(scanData)
        groupData = scanData{i};
        timestamps = groupData(:, 1);
        voltages = groupData(:, 2);

        % Filter the data by applying a threshold to remove small peaks
        threshold = 0.4; % Adjust the threshold value as needed
        filteredVoltages = voltages;
        filteredVoltages(voltages < threshold) = 0;

        % Find peaks in the filtered voltage signal
        [peaks, peakIndices] = findpeaks(filteredVoltages);

        % Access the peak values and their corresponding timestamps
        peakTimestamps = timestamps(peakIndices);
        peakVoltages = peaks;
        
        if numel(peakVoltages) >= 2
            % Find the two highest peaks
            [sortedPeaks, sortedIndices] = sort(peakVoltages, 'descend');
            highestPeaks = sortedPeaks(1:2);
            highestPeakIndices = peakIndices(sortedIndices(1:2));
            highestPeakTimestamps = peakTimestamps(sortedIndices(1:2));
    
            % Calculate the difference between the timestamps of the two highest peaks
            timeDifference = abs(diff(highestPeakTimestamps));
    
            timeDifferences = [timeDifferences; timeDifference];  % Append the time difference to the array
    
            % Display the time difference between the two highest peaks
            disp(['Timestamp Difference: ' num2str(timeDifference)]);
        else
            disp('Less than two peaks detected in the filtered voltage signal.');
        end

        % Plot the data in the same figure
        subplot(numel(scanData), 1, i);  % Create subplots for each data group
        plot(timestamps, voltages);
        hold on;
        scatter(timestamps(peakIndices), peaks, 'r', 'filled');
        xlabel('Timestamps');
        ylabel('Voltage');
        title('Voltage Signal with Detected Peaks');
        legend('Voltage Signal', 'Peaks');
        
    end

    % Calculate and display the mean value of the time differences
    meanTimeDifference = mean(timeDifferences);
    disp(['Mean Time Difference: ' num2str(meanTimeDifference)]);

end
