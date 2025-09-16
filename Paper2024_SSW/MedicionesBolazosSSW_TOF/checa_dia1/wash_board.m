close all;
clear;
s = daq('ni');
time=10;

% Add analog input channel
addinput(s, 'cDAQ1Mod1', 'ai0', 'Voltage');

addinput(s, 'cDAQ1Mod1', 'ai1', 'Voltage');

addinput(s, 'cDAQ1Mod1', 'ai2', 'Voltage');

% Configure acquisition parameters
s.Rate = 10240; % sample rate (Hz) 

% Plot data in real-time
data = read(s,seconds(time));
save('Checa_1_test3_vel10.mat','data')
figure;
plot(data,"Time", "cDAQ1Mod1_ai0")
figure;
plot(data,"Time", "cDAQ1Mod1_ai1")
figure;
plot(data,"Time", "cDAQ1Mod1_ai2")
