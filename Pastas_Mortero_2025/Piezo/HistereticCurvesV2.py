import numpy as np
import matplotlib.pyplot as plt
from scipy.signal import butter, filtfilt
import os

# ========= PARÁMETROS =========
FILTER_MODE = "bandpass"
FILTER_ORDER_BP = 2
DETREND = True
COMBINE_STRATEGY = "best"

# ========= CONSTANTES Y GEOMETRÍA =========
LB_TO_N = 4.4482216152605
MM_TO_M = 1e-3
d = 0.05   # m
h = 0.10   # m
A = np.pi * (d/2)**2  # m²

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

def clean_signal(x, fs, lowcut, highcut, detrend=True):
    y = x - np.nanmean(x) if detrend else x
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

# ========= ARCHIVOS =========
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

    t, disp_mm, F1_lb, F2_lb = data[:, 0], data[:, 1], data[:, 2], data[:, 3]
    fs = infer_fs_from_time(t)
    print(f"\n{file}: Fs≈{fs:.1f} Hz | Banda=[{lowcut}-{highcut}] Hz | f0≈{f0} Hz")

    # ---- Alineación ----
    disp_aligned, _ = align_sign_to_reference(disp_mm, F1_lb)
    F1_aligned, _ = align_sign_to_reference(F1_lb, disp_aligned)
    F2_aligned, _ = align_sign_to_reference(F2_lb, disp_aligned)
    F_combined = pick_force(F1_aligned, F2_aligned, strategy=COMBINE_STRATEGY)

    # ---- Filtrado ----
    disp_f = clean_signal(disp_aligned, fs, lowcut, highcut)
    force_f = clean_signal(F_combined, fs, lowcut, highcut)

    # ---- Normalización para visualización ----
    disp_c = disp_aligned - np.mean(disp_aligned)
    force_c = F_combined - np.mean(F_combined)
    disp_f_c = disp_f - np.mean(disp_f)
    force_f_c = force_f - np.mean(force_f)

    disp_c /= np.max(np.abs(disp_c))
    force_c /= np.max(np.abs(force_c))
    disp_f_c /= np.max(np.abs(disp_f_c))
    force_f_c /= np.max(np.abs(force_f_c))

    # ---- Porción central ----
    n = len(disp_f_c)
    frac = frac_keep / 100.0
    half = int((n * frac) / 2)
    center = n // 2
    i0, i1 = center - half, center + half
    disp_sel = disp_f_c[i0:i1]
    force_sel = force_f_c[i0:i1]

    # ====== CÁLCULO DE PENDIENTE REAL ======
    # Tomamos las señales filtradas en unidades reales
    disp_m = (disp_f[i0:i1] - np.mean(disp_f[i0:i1])) * MM_TO_M
    force_N = (force_f[i0:i1] - np.mean(force_f[i0:i1])) * LB_TO_N
    eps = disp_m / h
    sig = force_N / A  # Pa

    # Ajuste lineal (pendiente)
    p = np.polyfit(eps, sig, 1)
    E_Pa = p[0]
    E_MPa = E_Pa / 1e6
    print(f"   -> Módulo de Young estimado ≈ {E_MPa:.3f} MPa")

    # ====== GRÁFICA ======
    plt.figure(figsize=(7,6))
    plt.plot(disp_c, force_c, color="gray", alpha=0.5, label="Original (sin filtrar)")
    plt.plot(disp_sel, force_sel, color="red", lw=1.3, label="Filtrada")
    plt.plot(disp_sel, np.polyval(np.polyfit(disp_sel, force_sel, 1), disp_sel),
             color="orange", lw=2, label=f"Ajuste pendiente filtrada (E≈{E_MPa:.2f} MPa)")
    plt.title(f"Curva Histérica: {os.path.basename(file)} [{lowcut}-{highcut}] Hz")
    plt.xlabel("Desplazamiento normalizado [-]")
    plt.ylabel("Fuerza normalizada [-]")
    plt.legend()
    plt.grid(alpha=0.4)
    plt.tight_layout()
    plt.show()
