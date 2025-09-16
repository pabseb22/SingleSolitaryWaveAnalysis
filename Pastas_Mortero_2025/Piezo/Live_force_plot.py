
import nidaqmx
from nidaqmx.stream_readers import AnalogMultiChannelReader
from nidaqmx.constants import AcquisitionType
import numpy as np

# Configuration
sample_rate = 10 # Hz
duration = 10       # seconds for demo, adjust as needed
channels = ["cDAQ2Mod1/ai0","cDAQ2Mod1/ai1","cDAQ2Mod1/ai2"]
k_force= 50/2.5 #mv/lb los 2.5 es una constante de calibracion del sensor
k_force2 = 1000/9.915   # lb/v
k_LVDT=5.17409  #constante del LVDT mm/v



with nidaqmx.Task() as task:
    for channel_name in channels:
        task.ai_channels.add_ai_voltage_chan(channel_name, min_val=-10.0, max_val=10.0)
    task.timing.cfg_samp_clk_timing(rate=sample_rate, sample_mode=AcquisitionType.CONTINUOUS)
    reader = AnalogMultiChannelReader(task.in_stream)
    num_samples = 10  # Number of samples per update

    print("Live force value display started. Press Ctrl+C to stop.")
    task.start()
    try:
        while True:
            data = np.zeros((len(channels), num_samples))
            reader.read_many_sample(data, num_samples, timeout=1.0)
            
            # Print the most recent force value
            print(f"Ch0: {data[0, -1]*k_LVDT:.3f} mm | Ch1: {data[1, -1]*k_force:.3f} lb | Force: {data[2, -1]*k_force2:.3f} lb|", end='\r')
    except KeyboardInterrupt:
        print("\nStopped by user.")
    finally:
        task.stop()

