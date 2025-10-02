# files = ["ref0p4_120min_v6_f1.txt","ref0p4_120min_v6_f10.txt", "ref0p4_120min_v6_f20.txt", "ref0p4_120min_v6_f30.txt"]
# files = ["0p3/v2ref0_90min_v6_f1.txt","0p3/v2ref0_90min_v6_f10.txt", "0p3/v2ref0_90min_v6_f20.txt", "0p3/v2ref0_90min_v6_f30.txt", "0p3/v2ref0_90min_v6_f40.txt", "0p3/v2ref0_90min_v6_f50.txt", "0p3/v2ref0_90min_v6_f60.txt"]
# files = ["0p35/ref0p35_90min_v6_f1.txt","0p35/ref0p35_90min_v6_f10.txt", "0p35/ref0p35_90min_v6_f20.txt", "0p35/ref0p35_90min_v6_f30.txt", "0p35/ref0p35_90min_v6_f40.txt", "0p35/ref0p35_90min_v6_f50.txt", "0p35/ref0p35_90min_v6_f60.txt"]
# files = ["0p35/ref0p35_120min_v6_f1.txt","0p35/ref0p35_120min_v6_f10.txt", "0p35/ref0p35_120min_v6_f20.txt", "0p35/ref0p35_120min_v6_f30.txt", "0p35/ref0p35_120min_v6_f40.txt", "0p35/ref0p35_120min_v6_f50.txt"]
# files = ["0p40/ref0p4_90min_v6_f1.txt","0p40/ref0p4_90min_v6_f10.txt", "0p40/ref0p4_90min_v6_f20.txt", "0p40/ref0p4_90min_v6_f30.txt", "0p40/ref0p4_90min_v6_f40.txt", "0p40/ref0p4_90min_v6_f50.txt"]

import numpy as np
import matplotlib.pyplot as plt
from scipy.signal import butter, filtfilt
import os

# ========= PARÁMETROS =========
FILTER_ORDER = 3
USE_FORCE_COL = 3   # 2 o 3: elige qué columna de fuerza usar
DETREND = True      # quitar media para centrar señales

# Geometría de la muestra
d = 0.05   # m (50 mm)
h = 0.10   # m (100 mm)
A = np.pi * (d/2)**2  # área transversal en m²

# ========= FUNCIONES DE FILTRADO =========
def infer_fs_from_time(t):
    dt = np.diff(t)
    dt = dt[np.isfinite(dt)]
    fs = 1.0 / np.mean(dt)
    return fs

def butter_bandpass(data, lowcut, highcut, fs, order=3):
    nyq = 0.5 * fs
    low = lowcut / nyq
    high = highcut / nyq
    b, a = butter(order, [low, high], btype='band')
    return filtfilt(b, a, data)

def clean_signal(x, fs, lowcut, highcut):
    y = x.copy()
    if DETREND:
        y = y - np.nanmean(y)
    return butter_bandpass(y, lowcut, highcut, fs, order=FILTER_ORDER)

# ========= ARCHIVOS =========
files = [
    "0p3/v2ref0_90min_v6_f1.txt",
    "0p3/v2ref0_90min_v6_f10.txt",
    "0p3/v2ref0_90min_v6_f20.txt",
    "0p3/v2ref0_90min_v6_f30.txt",
    "0p3/v2ref0_90min_v6_f40.txt",
    "0p3/v2ref0_90min_v6_f50.txt",
    "0p3/v2ref0_90min_v6_f60.txt"
]

# ========= ARREGLO DE BANDAS =========
bandas = [
    (0.5, 2),    # f1
    (5, 15),     # f10
    (15, 25),    # f20
    (25, 35),    # f30
    (35, 45),    # f40
    (45, 55),    # f50
    (55, 65)     # f60
]

# ========= PROCESAR =========
plt.figure(figsize=(9,7))
legend_labels = []

for file, (lowcut, highcut) in zip(files, bandas):
    try:
        data = np.loadtxt(file, delimiter='\t', skiprows=1)
    except Exception as e:
        print(f"[WARN] No pude leer {file}: {e}")
        continue

    if data.shape[1] < 4:
        print(f"[WARN] {file} no tiene 4 columnas esperadas.")
        continue

    t = data[:,0]
    disp = data[:,1]      # mm
    force = data[:, USE_FORCE_COL-1]  # lb

    # Inferir Fs
    fs = infer_fs_from_time(t)
    print(f"\n{file}: Fs≈{fs:.2f} Hz | Banda = [{lowcut}, {highcut}] Hz")

    # Conversión de unidades
    F = force * 4.44822       # lb → N
    d_m = disp / 1000.0       # mm → m

    # Pasar a esfuerzo-deformación
    stress = F / A            # Pa
    strain = d_m / h          # adim.

    # Filtrar
    stress_f = clean_signal(stress, fs, lowcut, highcut)
    strain_f = clean_signal(strain, fs, lowcut, highcut)

    # Recortar a ventana intermedia (ejemplo: 30%-60%)
    n = len(stress_f)
    start, end = int(0.3*n), int(0.6*n)
    stress_cut = stress_f[start:end]
    strain_cut = strain_f[start:end]

    # Calcular pendiente (módulo aparente)
    coeffs = np.polyfit(strain_cut, stress_cut, 1)
    slope = coeffs[0] / 1e6  # Pa → MPa
    print(f"  -> Pendiente (E_aprox) ≈ {slope:.2f} MPa")

    # Graficar ciclo reducido
    plt.plot(strain_cut, stress_cut/1e6, linewidth=1.0)  # esfuerzo en MPa
    legend_labels.append(f"{os.path.basename(file)} (E={slope:.1f} MPa)")

# Etiquetas
plt.xlabel("Deformación unitaria ε [-]")
plt.ylabel("Esfuerzo σ [MPa]")
plt.title("Ciclos histéréticos (recorte intermedio)")
plt.legend(legend_labels, fontsize=8)
plt.grid(True, alpha=0.4)
plt.tight_layout()
plt.show()

