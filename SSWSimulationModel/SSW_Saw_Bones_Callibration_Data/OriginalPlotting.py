import numpy as np
import matplotlib.pyplot as plt
import scipy.io

# Load the saved data from the MAT files
data_mat = scipy.io.loadmat('C:/Users/pablo/Desktop/InvestigacionUSFQ/SSWCompleteAnalysis/SingleSolitaryWaveAnalysis/SSWSimulationModel/Numerical_Saw_Bones_Data/PCF_445.00_num_data_poi0.30_v00.26.mat')
FA91 = data_mat['FA91'].flatten().real
t = data_mat['t'].flatten()

# Plot the data
plt.figure(figsize=(10, 6))
plt.plot(t, FA91, 'b-', label='Numerical Data')
plt.title('Numerical Data')
plt.xlabel('Time (s)')
plt.ylabel('Force')
plt.legend()
plt.grid(True)
plt.show()
