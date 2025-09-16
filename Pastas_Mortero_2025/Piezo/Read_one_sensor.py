import nidaqmx
from nidaqmx.stream_readers import AnalogMultiChannelReader
from nidaqmx.constants import AcquisitionType
from nidaqmx.system import System

import numpy as np
import matplotlib.pyplot as plt
import time
from scipy.signal import butter, filtfilt

# List available devices and channels
# system = System.local()
# for device in system.devices:
#     print(f"Device: {device.name}")
#     for channel in device.ai_physical_chans:
#         print(f"  AI Channel: {channel.name}")

# Bandpass filter definition
def butter_lowpass_filter(data, cutoff, fs, order=2):
    nyq = 0.5 * fs  # Nyquist frequency
    normal_cutoff = cutoff / nyq
    b, a = butter(order, normal_cutoff, btype='low', analog=False)
    y = filtfilt(b, a, data)
    return y


# Configuration
name_file = "ref0p4_120min_v6_f30"
sample_rate = 1000  # Hz
duration = 1# seconds
num_samples = int(sample_rate * duration)
#channels = ["cDAQ1Mod1/ai0", "cDAQ1Mod1/ai1"]  # Update if needed
channels = ["cDAQ2Mod1/ai0", "cDAQ2Mod1/ai1", "cDAQ2Mod1/ai2"] 
# Data acquisition
with nidaqmx.Task() as task:
    # Configure analog input channels
    for channel_name in channels:
        task.ai_channels.add_ai_voltage_chan(channel_name, min_val=-10.0, max_val=10.0)
    
    # Set sampling configuration
    task.timing.cfg_samp_clk_timing(
        rate=sample_rate,
        samps_per_chan=num_samples,
        sample_mode=AcquisitionType.FINITE
    )

    # Prepare data buffer
    data = np.zeros((len(channels), num_samples))

    print("Recording started...")
    start_time = time.time()

    # Read samples
    reader = AnalogMultiChannelReader(task.in_stream)
    reader.read_many_sample(data, num_samples, timeout=duration + 1.0)

    end_time = time.time()
    print(f"Recording completed! Duration: {end_time - start_time:.2f} seconds.")

# Time axis
time_axis = np.linspace(0, duration, num_samples)

# Filter signal from Channel 0
filtered_signal_0 = butter_lowpass_filter(data[0], cutoff=250.0, fs=sample_rate, order=2)

k_LVDT=5.17409  #constante del LVDT mm/v

displ_0=filtered_signal_0*k_LVDT 

k_force= 50/2.5 #mv/lb los 2.5 es una constante de calibracion del sensor
Force_1=data[1]*k_force  # Convert to lb

k_celda2=1000/9.915  # lb/v
Force_2=k_celda2*data[2]  # Convert to lb

# Plot 1: Filtered Channel 0
plt.figure(figsize=(10, 5))
plt.plot(time_axis, displ_0, label='Displacment (mm) (Channel 0)')
plt.xlabel('Time (s)')
plt.ylabel('Displacment (mm)')
plt.title('Displacment Channel 0')

plt.grid(True)

plt.figure(figsize=(10, 5))
plt.plot(time_axis, Force_1, label='Force (Lb) (Channel 1)')
plt.xlabel('Time (s)')
plt.ylabel('Force (Lb)')
plt.title('Force Channel 1')
plt.grid(True)

plt.figure(figsize=(10, 5))
plt.plot(time_axis, Force_2)
plt.xlabel('Time (s)')
plt.ylabel('Force (Lb)')
plt.title('Force Channel 3')
plt.grid(True)

plt.figure(figsize=(10, 5))
plt.plot(displ_0, Force_2, label='Force (Lb) (Channel 1)')
plt.xlabel('Displacment (mm) (Channel 0)')
plt.ylabel('Force (Lb) ')
plt.grid(True)
plt.title('Force vs Displacment')
plt.show()

# save data
#Save time_axis, Channel 0, and Channel 1 to a tab-delimited TXT file

np.savetxt(name_file + ".txt", np.column_stack((time_axis, displ_0, Force_1, Force_2)),
           delimiter='\t', header='Time(s)\\disp(mm)\\Force(Lb)\\Force(Lb)', comments='')
