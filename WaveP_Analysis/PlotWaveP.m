% Absolute path to the folder where CSV files are located
folder_path = 'C:\Users\pablo\Desktop\InvestigacionUSFQ\SSWCompleteAnalysis\ResultadosVelocidadOndaP';

% File index to plot (change to the file you want to visualize)
file_index = 4;

% Current file name
file_name = sprintf('ProbetaM1_Run#%d.csv', file_index);

% Full path to the CSV file
file_path = fullfile(folder_path, file_name);

% Load data from the CSV file
data = csvread(file_path, 11, 0); % Ignore the first 10 header rows

% Extract columns for time, signal1, and signal2
time = data(:, 1); % First column
signal1 = data(:, 2); % Second column
signal2 = data(:, 3); % Third column

% Plot both signals aligned on the x-axis (y = 0)
figure;
plot(time, signal1 - mean(signal1), 'b', time, signal2 - mean(signal2), 'r');
title('Signals 1 and 2');
xlabel('Time (s)');
ylabel('Amplitude');
legend('Signal 1', 'Signal 2');
