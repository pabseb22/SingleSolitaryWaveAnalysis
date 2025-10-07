%% Description:
% This script processes .mat files containing wave signal data to identify 
% peak times, compute Time-of-Flight (TOF), and interpolate the corresponding 
% modulus of elasticity (Young's modulus) based on simulation calibration data.

%% Setup

close all; clear all;

% Define folder containing measurement .mat files
folder_path = 'C:\Users\pablo\Desktop\InvestigacionUSFQ\SSWCompleteAnalysis\SingleSolitaryWaveAnalysis\Pastas_Mortero_2025\0p30';

% Define desired Poisson's ratio for interpolation
desiredPoisson = 0.25;

% Poisson ratios used in the calibration simulation
pois = [0.1, 0.3, 0.5];

% Young's modulus values used in simulation (in Pascals)
mody = [10e6, 100e6, 300e6, 500e6, 700e6, 1000e6];

% Threshold for identifying peaks in the signal
threshold = 0.00002;

% Get list of all .mat files in the folder
files = dir(fullfile(folder_path, '*.mat'));

% Load calibration TOF data for interpolation
load('C:\Users\pablo\Desktop\InvestigacionUSFQ\SSWCompleteAnalysis\SingleSolitaryWaveAnalysis\SSWSimulationModel\TOF.mat', 'TOF_data');

%TOF_DATA= [0.0021867940	0.0015349550	0.0012459910	0.0011303080 0.0010624430	0.00099800000;
% 0.0021597190	0.0015245800	0.0012349920	0.0011210800	0.0010543160 0.00099000000;
% 0.0021497050	0.0014839440	0.0011976650 0.0010891450	0.0010265560	0.00096600000]

% Convert cell array to numeric matrix and interpolate TOF for desired Poisson ratio
numericTOF_data = cell2mat(TOF_data); 
interp_TOF = interp1(pois, numericTOF_data, desiredPoisson, 'linear', 'extrap');

% Initialize results table
resultsTable = table('Size', [0 4], ...
                     'VariableTypes', {'string', 'double', 'double', 'double'}, ...
                     'VariableNames', {'Filename', 'Group', 'TimeDifference', 'ModulusE'});

%% Main Processing Loop

for fileIdx = 1:length(files)
    file_name = files(fileIdx).name;
    file_path = fullfile(folder_path, file_name);

    % Load scanData from the .mat file
    load(file_path);
    fprintf('\nProcessing file: %s\n', file_name);

    for groupIdx = 1:numel(scanData)
        data = scanData{groupIdx};
        xdata = data(:, 1);  % Time
        ydata = data(:, 2);  % Amplitude

        % Zero out values below the noise threshold
        filteredYData = ydata;
        filteredYData(ydata < threshold) = 0;

        % Detect peaks
        [peaks, peakIndices] = findpeaks(filteredYData);
        peakXData = xdata(peakIndices);  % Corresponding times of peaks

        if numel(peaks) >= 2
            % Get the two highest peaks
            [~, sortedIndices] = sort(peaks, 'descend');
            peakTimes = peakXData(sortedIndices(1:2));

            % Compute Time-of-Flight (TOF)
            timeDifference = abs(diff(peakTimes));

            % Interpolate log10(E)
            log_interp_E = interp1(interp_TOF, log10(mody), timeDifference, 'linear', 'extrap');
            
            % Convert back from log scale
            modulusE = 10^log_interp_E;
            
            % Append result row
            resultsTable = [resultsTable; {file_name, groupIdx, timeDifference, modulusE/1e6}];
            
            % Display results
            fprintf('  Group %d - TOF: %.6f s - E: %.2f MPa\n', groupIdx, timeDifference, modulusE/1e6);

            % Regular Interpolation 
            % % Interpolate modulus of elasticity from calibration data
            % modulusE = interp1(interp_TOF, mody, timeDifference, 'linear', 'extrap');
            % 


        else
            fprintf('  Group %d: Less than two peaks detected.\n', groupIdx);
        end
    end
    resultsTable = [resultsTable; {'---', NaN, NaN, NaN}];
end

%% Save Results to Excel

% excel_filename = fullfile(folder_path, 'time_differences_results.xlsx');
% writetable(resultsTable, excel_filename);
% fprintf('\nAll time differences saved to: %s\n', excel_filename);
