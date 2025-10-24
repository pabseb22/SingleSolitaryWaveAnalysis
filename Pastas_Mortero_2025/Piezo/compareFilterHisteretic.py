import numpy as np
import matplotlib.pyplot as plt
from scipy.signal import butter, filtfilt, savgol_filter
import os

# ========= PARÁMETROS =========
FILTER_MODE = "bandpass"     # "savgol" | "bandpass" | "lowpass"
FILTER_ORDER_BP = 2        # Orden del filtro pasa-banda
DETREND = True
COMBINE_STRATEGY = "best"  # "average" o "best"

# ========= FUNCIONES =========
def infer_fs_from_time(t):
    dt = np.diff(t)
    dt = dt[np.isfinite(dt)]
    return 1.0 / np.mean(dt)

def butter_bandpass(x, lowcut, highcut, fs, order=2):
    nyq = 0.5 * fs
    low = max(1e-6, lowcut / nyq)
    high = min(0.999, highcut / nyq)
    b, a = butter(order, [low, high], btype='band')
    return filtfilt(b, a, x)

def clean_signal(x, fs, lowcut=None, highcut=None, f0=None, detrend=True):
    y = x - np.nanmean(x) if detrend else x
    if FILTER_MODE == "bandpass" and lowcut is not None and highcut is not None:
        return butter_bandpass(y, lowcut, highcut, fs, order=FILTER_ORDER_BP)

def align_sign_to_reference(y, ref):
    c = np.corrcoef(y, ref)[0, 1]
    return (y if c >= 0 else -y), abs(c)

def pick_force(f1, f2, strategy="average"):
    if strategy == "best":
        r1 = np.sqrt(np.mean(f1**2))
        r2 = np.sqrt(np.mean(f2**2))
        return f1 if r1 >= r2 else f2
    else:
        return 0.5 * (f1 + f2)

# ========= ARCHIVOS Y BANDAS =========
files = [
      "0p35/ref0p35_90min_v6_f1.txt",
         "0p35/ref0p35_90min_v6_f10.txt", 
         "0p35/ref0p35_90min_v6_f20.txt", 
         "0p35/ref0p35_90min_v6_f30.txt", 
         "0p35/ref0p35_90min_v6_f40.txt", 
         "0p35/ref0p35_90min_v6_f50.txt", 
         "0p35/ref0p35_90min_v6_f60.txt"]

# Frecuencia fundamental
frecuencias_base = [1, 10, 20, 30, 40, 50, 60]
bandas = [(f-6, f+6) for f in frecuencias_base]

# Porcentaje del centro a mostrar (por curva)
porciones = [40, 35, 35, 30, 35, 30, 30]

# ========= PROCESAR Y GRAFICAR =========
for (file, (lowcut, highcut), f0, frac_keep) in zip(files, bandas, frecuencias_base, porciones):
    try:
        data = np.loadtxt(file, delimiter="\t", skiprows=1)
    except Exception as e:
        print(f"[WARN] No pude leer {file}: {e}")
        continue

    if data.shape[1] < 4:
        print(f"[WARN] {file} no tiene 4 columnas esperadas.")
        continue

    t = data[:, 0]
    disp_mm = data[:, 1]
    force1_lb = data[:, 2]
    force2_lb = data[:, 3]

    fs = infer_fs_from_time(t)
    print(f"\n{file}: Fs≈{fs:.1f} Hz | Banda=[{lowcut}-{highcut}] Hz | f0≈{f0} Hz | Porción≈{frac_keep}%")

    # Señales originales
    disp = disp_mm
    F1 = force1_lb
    F2 = force2_lb

    # Alineación de signos
    disp_aligned, _ = align_sign_to_reference(disp, F1)
    F1_aligned, _ = align_sign_to_reference(F1, disp_aligned)
    F2_aligned, _ = align_sign_to_reference(F2, disp_aligned)
    F_combined = pick_force(F1_aligned, F2_aligned, strategy=COMBINE_STRATEGY)

    # Filtrado suave
    disp_f = clean_signal(disp_aligned, fs, lowcut, highcut, f0=f0)
    force_f = clean_signal(F_combined, fs, lowcut, highcut, f0=f0)

    # Centrado y normalización (solo para comparar forma)
    disp_c = disp_aligned - np.mean(disp_aligned)
    force_c = F_combined - np.mean(F_combined)
    disp_f_c = disp_f - np.mean(disp_f)
    force_f_c = force_f - np.mean(force_f)

    disp_c /= np.max(np.abs(disp_c))
    force_c /= np.max(np.abs(force_c))
    disp_f_c /= np.max(np.abs(disp_f_c))
    force_f_c /= np.max(np.abs(force_f_c))

    # Porción central del filtrado
    n = len(disp_f_c)
    frac = frac_keep / 100.0
    half = int((n * frac) / 2)
    center = n // 2
    i0, i1 = center - half, center + half
    disp_sel = disp_f_c[i0:i1]
    force_sel = force_f_c[i0:i1]

    # ===== GRAFICAR =====
    plt.figure(figsize=(7, 6))
    plt.plot(disp_c, force_c, color="gray", alpha=0.5, label="Original (sin filtrar)")
    plt.plot(disp_sel, force_sel, color="red", lw=1.3, label=f"Filtrado suave ({FILTER_MODE})")
    plt.title(f"Curva Histérica: {os.path.basename(file)} [{lowcut}-{highcut}] Hz")
    plt.xlabel("Desplazamiento normalizado [-]")
    plt.ylabel("Fuerza normalizada [-]")
    plt.legend()
    plt.grid(alpha=0.4)
    plt.tight_layout()
    plt.show()
