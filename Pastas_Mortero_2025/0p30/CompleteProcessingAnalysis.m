close all; clear all;
%Folder Definition

folder_path = "C:\Users\Juan Pablo V\OneDrive - Universidad San Francisco de Quito\USFQ 2021\Investigaciones\Pastas_Mortero\0p30";
file_name = 'Ref_0p30_0h';


% % Absolute path to the folder where CSV files are located
% folder_path_WaveP = "C:\Users\pablo\Desktop\InvestigacionUSFQ\SSWCompleteAnalysis\ResultadosOndaP\ResultadosVelocidadOndaPProctorsPabloMajo2";
% % Base name for the files
% base_name = 'M5_56_Mod_Run#';
% % Number of runs to analyze
% num_runs = 5;
% 
% % Poisson's ratio values used in the simulation
% pois = [0.1, 0.3, 0.5];
% 
% % Young's modulus values used in the simulation
% mody = [10e6, 100e6, 300e6, 500e6, 700e6, 1000e6];
% 
file_path = fullfile(folder_path, file_name);
load(file_path);
% 
% % Load TOF_data from the MAT file
% %load('C:\Users\pablo\Desktop\InvestigacionUSFQ\SSWCompleteAnalysis\SingleSolitaryWaveAnalysis\SSWSimulationModel\TOF.mat', 'TOF_data');
% 
% 
% % Specify the desired Poisson's ratio for interpolation
timeDifferences = [];  % Initialize an empty array to store the time differences
peak_ratio_all=[];
% Preallocate a cell array to store time_between values
time_between_all = cell(1, numel(scanData));

figures = length(scanData);


% Part 1: Process Voltage Signal Data

for i = 1:numel(scanData)
    % Extract data for each figure
    data = scanData{i};
    xdata = data(:, 1); % Assuming the first column contains the x-values
    ydata = data(:, 2); % Assuming the second column contains the y-values


    % Filter the data by applying a threshold to remove small peaks
    threshold = 0.002; % Adjust the threshold value as needed
    filteredYData = ydata;
    filteredYData(ydata < threshold) = 0;

    % Find peaks in the filtered y-data
    [peaks, peakIndices] = findpeaks(filteredYData, ...
    'MinPeakHeight', 0.001, ...
    'MinPeakDistance', 10); 

    % Access the peak values and their corresponding x-values (timestamps)
    peakXData = xdata(peakIndices);
    
        % Plot data for each figure
    subplot(figures,1 , i);
    plot(xdata, ydata);
    xlabel('X-axis Label'); % Add appropriate labels
    ylabel('Y-axis Label');
    title(['Data Plot ' num2str(i)]);
    grid on; % Add a grid for better visualization
    hold on
    scatter(peakXData, ydata(peakIndices), 'filled')
    hold off

    y_peaks=ydata(peakIndices);
    peak_ratio=y_peaks(2)/y_peaks(1);

    peak_ratio_all=[peak_ratio_all,peak_ratio];

    % Calculate time differences between peaks
    time = peakXData;
    time_between = diff(time);
    disp(['Loop ' num2str(i) ' - time_between:']);
    disp(time_between);
    % Store time_between for this iteration
    time_between_all{1,i} = time_between;
end



% % Part 2: Plot TOF Data
% 
% % Convert the cell array to a numeric matrix
% numericTOF_data = cell2mat(TOF_data);
% 
% % Perform linear interpolation for the desired Poisson's ratio
% interp_values = interp1(pois, numericTOF_data, desiredPoisson, 'linear', 'extrap');
% 
% % Display the interpolated values for the desired Poisson's ratio
% % disp(['Interpolated values for Poisson''s ratio ' num2str(desiredPoisson) ':']);
% % disp(interp_values);
% 
% % Part 1.2: Interpolation for Young's Modulus
% 
% % Iterate through each time difference
% for idx = 1:length(timeDifferences)
%     % Use the idx-th time difference for interpolation
%     desiredTOFValue = timeDifferences(idx);
%     A_TOF_Values{idx} = desiredTOFValue;
%     % Perform linear interpolation for the desired Poisson's ratio along columns
%     interp_mody_values = interp1(interp_values, mody, desiredTOFValue, 'linear', 'extrap');
%     A_Mod_Interpolated{idx} = interp_mody_values/1e6;
%         % Check if the interpolated value is within bounds
%     if interp_mody_values >= min(mody) && interp_mody_values <= max(mody)
%         % Display the interpolated Young's Modulus for the current TOF value
%         disp(['TOF: ' num2str(desiredTOFValue) '-- E: ' num2str(interp_mody_values/1e6) ' Mpa']);
%     else
%         disp(['TOF: ' num2str(desiredTOFValue) ' -- Interpolated E is out of bounds']);
%     end
% end
% 
% % % Create a new figure for the final plot
% % figure('Position', [100, 250, 800, 400]); % Adjust the position and size as needed
% % hold on;
% % 
% % % Define a set of colors for each run
% % runColors = lines(num_runs);
% % legendStrings = cell(1, num_runs);
% % 
% % for file_index = 1:num_runs
% %     % Current file name
% %     file_name = sprintf('%s%d.csv', base_name, file_index);
% % 
% %     % Full path to the CSV file
% %     file_path = fullfile(folder_path_WaveP, file_name);
% % 
% %     % Load data from the CSV file
% %     data = csvread(file_path, 11, 0); % Ignore the first 10 header rows
% % 
% %     % Extract columns for time, signal1, and signal2
% %     time = data(:, 1); % First column
% %     signal1 = data(:, 2); % Second column
% %     signal2 = data(:, 3); % Third column
% %     sigma = 10;
% % 
% %     signal1 = imgaussfilt(signal1, sigma);
% %     signal2 = imgaussfilt(signal2, sigma);
% %     threshold_Peaks = 0.02;
% % 
% %     % Find the first peak in the absolute values of original signals
% %     [~, loc1_original] = findpeaks(abs(signal1), 'MinPeakHeight', threshold_Peaks, 'NPeaks', 1);
% %     [~, loc2_original] = findpeaks(abs(signal2), 'MinPeakHeight', threshold_Peaks, 'NPeaks', 1);
% % 
% %     % Get the time of the first peak in signals 1 and 2 for original signals
% %     time_peak1_original = time(loc1_original);
% %     time_peak2_original = time(loc2_original);
% % 
% %     % Calculate the time delays
% %     time_delay_original = (time_peak2_original - time_peak1_original)*1e6;
% %     A_TV_Results{file_index} = time_delay_original;
% % 
% %     % Display the time delays for original signals
% %     fprintf('File %d : %.3f micro-seconds.\n', file_index, time_delay_original);
% % 
% %     % Plot the detected peaks for each run with different colors
% %     plot(time, signal1, 'Color', runColors(file_index, :));
% %     plot(time, signal2, 'Color', runColors(file_index, :));
% %     scatter(time_peak1_original, signal1(loc1_original), 'MarkerEdgeColor', runColors(file_index, :), 'Marker', 'o');
% %     scatter(time_peak2_original, signal2(loc2_original), 'MarkerEdgeColor', runColors(file_index, :), 'Marker', 'o');
% %     %plot(time, signal1, time, signal2, time_peak1_original, signal1(loc1_original), 'bo', time_peak2_original, signal2(loc2_original), 'ro', 'Color', runColors(file_index, :));
% %     % Create legend string for the current run
% %     %legendStrings{file_index} = ['Run ' num2str(file_index)];
% % end
% % title('Detected Peaks in Original Signals');
% % xlabel('Time (s)');
% % ylabel('Amplitude');
% % grid on;
% % hold off;
% % 
% % % Add a legend outside the loop using the legendStrings cell array
% % %legend(legendStrings, 'Location', 'best');