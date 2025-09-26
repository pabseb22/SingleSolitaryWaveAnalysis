import numpy as np
import matplotlib.pyplot as plt
from scipy.signal import butter, filtfilt, iirnotch
import os, glob


# ========= PARÁMETROS AJUSTABLES =========
APPLY_LOWPASS = True
CUTOFF_HZ = 70.0        # 3–20 Hz suele ir bien para ciclos lentos
FILTER_ORDER = 3

DETREND = True            # quitar media para centrar señales
USE_FORCE_COL = 3         # 2 o 3: elige cuál columna de fuerza usar

# ========= FUNCIONES DE FILTRADO =========
def infer_fs_from_time(t):
    dt = np.diff(t)
    dt = dt[np.isfinite(dt)]
    # Quita outliers groseros en dt (si los hubiera)
    med = np.median(dt)
    mad = np.median(np.abs(dt - med)) + 1e-12
    dt_clean = dt[np.abs(dt - med) < 5*mad]
    fs = 1.0 / np.mean(dt_clean)
    return fs, dt_clean.min(), dt_clean.max(), dt_clean.std()

def butter_lowpass(data, cutoff, fs, order=3):
    nyq = 0.5 * fs
    wn = cutoff / nyq
    b, a = butter(order, wn, btype='low', analog=False)
    return filtfilt(b, a, data)

def notch_60hz(data, fs, q=30.0, f0=60.0):
    b, a = iirnotch(w0=f0/(fs/2), Q=q)
    return filtfilt(b, a, data)

def clean_signal(x, fs):
    y = x.copy()
    if DETREND:
        y = y - np.nanmean(y)
    if APPLY_LOWPASS:
        y = butter_lowpass(y, CUTOFF_HZ, fs, order=FILTER_ORDER)
    return y

# ========= PROCESAR VARIOS ARCHIVOS =========

folder = os.path.join("0p3")
# files = sorted(glob.glob(os.path.join(folder, "*.txt")))

# files = ["ref0p4_120min_v6_f1.txt","ref0p4_120min_v6_f10.txt", "ref0p4_120min_v6_f20.txt", "ref0p4_120min_v6_f30.txt"]
# files = ["0p3/v2ref0_90min_v6_f1.txt","0p3/v2ref0_90min_v6_f10.txt", "0p3/v2ref0_90min_v6_f20.txt", "0p3/v2ref0_90min_v6_f30.txt", "0p3/v2ref0_90min_v6_f40.txt", "0p3/v2ref0_90min_v6_f50.txt", "0p3/v2ref0_90min_v6_f60.txt"]
# files = ["0p35/ref0p35_90min_v6_f1.txt","0p35/ref0p35_90min_v6_f10.txt", "0p35/ref0p35_90min_v6_f20.txt", "0p35/ref0p35_90min_v6_f30.txt", "0p35/ref0p35_90min_v6_f40.txt", "0p35/ref0p35_90min_v6_f50.txt", "0p35/ref0p35_90min_v6_f60.txt"]
# files = ["0p35/ref0p35_120min_v6_f1.txt","0p35/ref0p35_120min_v6_f10.txt", "0p35/ref0p35_120min_v6_f20.txt", "0p35/ref0p35_120min_v6_f30.txt", "0p35/ref0p35_120min_v6_f40.txt", "0p35/ref0p35_120min_v6_f50.txt"]
files = ["0p40/ref0p4_90min_v6_f1.txt","0p40/ref0p4_90min_v6_f10.txt", "0p40/ref0p4_90min_v6_f20.txt", "0p40/ref0p4_90min_v6_f30.txt", "0p40/ref0p4_90min_v6_f40.txt", "0p40/ref0p4_90min_v6_f50.txt"]



if not files:
    print("No se encontraron .txt en la carpeta actual.")
else:
    print("Archivos encontrados:")
    for f in files:
        print("  -", f)

    plt.figure(figsize=(9,7))
    legend_labels = []

    for file in files:
        try:
            # Lee saltando el encabezado
            data = np.loadtxt(file, delimiter='\t', skiprows=1)
        except Exception as e:
            print(f"[WARN] No pude leer {file}: {e}")
            continue

        # Validación básica
        if data.shape[1] < 4:
            print(f"[WARN] {file} no tiene 4 columnas esperadas.")
            continue

        t = data[:,0]
        disp = data[:,1]
        force = data[:, USE_FORCE_COL-1]  # columnas 2 o 3 para fuerza

        # Inferir Fs
        fs, dt_min, dt_max, dt_std = infer_fs_from_time(t)
        print(f"\n{file}: Fs≈{fs:.2f} Hz | dt_min={dt_min:.6f}s dt_max={dt_max:.6f}s dt_std={dt_std:.2e}")

        # Limpiar señales (sin distorsionar fase)
        disp_f = clean_signal(disp, fs)
        force_f = clean_signal(force, fs)

        # Graficar ciclo histérico
        plt.plot(disp_f, force_f, linewidth=1.0)
        legend_labels.append(f"{file}")

    plt.xlabel("Desplazamiento (mm)")
    plt.ylabel("Fuerza (Lb)")
    plt.title("Ciclos histéréticos: Fuerza vs Desplazamiento")
    if legend_labels:
        plt.legend(legend_labels, fontsize=8)
    plt.grid(True, alpha=0.4)
    plt.tight_layout()
    plt.show()
