import numpy as np
import matplotlib.pyplot as plt
import scipy.io
import pandas as pd
from scipy.signal import find_peaks

# Load the saved data from the MAT file
data_mat = scipy.io.loadmat('C:/Users/pablo/Desktop/InvestigacionUSFQ/SSWCompleteAnalysis/SingleSolitaryWaveAnalysis/SSWSimulationModel/Numerical_Saw_Bones_Data/PCF_16.00_num_data_poi0.30_v00.26.mat')
FA91 = data_mat['FA91'].flatten().real
t = data_mat['t'].flatten()

# Define the downsampling factor
downsample_factor = 1000

# Downsample the data
middle_index = len(FA91) // 2000
FA91_downsampled = np.concatenate([FA91[:middle_index], FA91[middle_index::downsample_factor]])
t_downsampled = np.concatenate([t[:middle_index], t[middle_index::downsample_factor]])

# Cut values exceeding the threshold
threshold = 0.002476
valid_indices = (t_downsampled > 0.0002) & (t_downsampled < threshold)

FA91_downsampled = FA91_downsampled[valid_indices]
t_downsampled = t_downsampled[valid_indices]

# Find peaks in the downsampled data
peaks, _ = find_peaks(FA91_downsampled)
if len(peaks) < 2:
    raise ValueError("Not enough peaks found in the downsampled data.")

# Find the second highest peak
peak_values = FA91_downsampled[peaks]
second_highest_peak_index = np.argsort(peak_values)[-2]
highest_peak_value = peak_values[np.argmax(peak_values)]
print(highest_peak_value)

second_highest_peak_value = peak_values[second_highest_peak_index]
print(second_highest_peak_value)


# Normalize the data based on the second highest peak
FA91_normalized = FA91_downsampled / highest_peak_value

# Find the first highest peak
first_highest_peak_index = np.argsort(peak_values)[-2]
first_highest_peak_t = t_downsampled[peaks[first_highest_peak_index]]

# Modify around 10% of y-values from the first peak
peak_start_index = np.searchsorted(t_downsampled, first_highest_peak_t - 0.1 * (t_downsampled[-1] - t_downsampled[0]))
peak_end_index = np.searchsorted(t_downsampled, first_highest_peak_t + 0.1 * (t_downsampled[-1] - t_downsampled[0]))
FA91_normalized[peak_start_index:peak_end_index] *= 0.7

# Align the maximum value to the y-axis (x = 0)
max_index = np.argmax(FA91_normalized)
x_shift = -t_downsampled[max_index]  # Shift x-values so that max value aligns with x = 0
t_downsampled_aligned = t_downsampled + x_shift

# Print sizes
print(f"Original data size: {len(FA91)}")
print(f"Downsampled data size: {len(FA91_downsampled)}")

# Plot both the original and processed data
plt.figure(figsize=(12, 6))
plt.plot(t_downsampled_aligned, FA91_normalized, label='Processed Data', color='orange', linewidth=2)
plt.title('Original vs Processed Data')
plt.xlabel('Time (s)')
plt.ylabel('Normalized Force')
plt.legend()
plt.grid(True)

plt.figure(figsize=(12, 6))
plt.plot(t, FA91, label='Original Data', alpha=0.6)

plt.show()

# Save the processed data to an Excel file
downsampled_file_path = 'PCF_05_num_data_v2_processed.xlsx'
processed_data = pd.DataFrame({
    'Time': t_downsampled_aligned,
    'Force': FA91_normalized
})

processed_data.to_excel(downsampled_file_path, index=False)
print(f"Processed data saved to: {downsampled_file_path}")
