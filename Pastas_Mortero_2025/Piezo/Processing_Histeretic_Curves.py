# # ========= ARCHIVOS Y BANDAS =========
# files = [
#     "0p3/v2ref0_90min_v6_f1.txt",
#     "0p3/v2ref0_90min_v6_f10.txt",
#     "0p3/v2ref0_90min_v6_f20.txt",
#     "0p3/v2ref0_90min_v6_f30.txt",
#     "0p3/v2ref0_90min_v6_f40.txt",
#     "0p3/v2ref0_90min_v6_f50.txt",
#     "0p3/v2ref0_90min_v6_f60.txt"
# ]

# files = [
#       "0p35/ref0p35_90min_v6_f1.txt",
#          "0p35/ref0p35_90min_v6_f10.txt", 
#          "0p35/ref0p35_90min_v6_f20.txt", 
#          "0p35/ref0p35_90min_v6_f30.txt", 
#          "0p35/ref0p35_90min_v6_f40.txt", 
#          "0p35/ref0p35_90min_v6_f50.txt", 
#          "0p35/ref0p35_90min_v6_f60.txt"]


# Graphs: 
# 1. Slope (ModE) vs frequency. para tres relaciones
# Frequency en el eje x, indicada en el archivo. desde 10 Hz hasta 60 Hz. Ploteando la pendiente.

# 2. ModeE bolazo contra Tof numerico y experimental (valores de las hiteretizas)
# En la misma grafia de 


# 3. Ciclos histereticos en bonito.

files = ["0p40/ref0p4_90min_v6_f1.txt",
"0p40/ref0p4_90min_v6_f10.txt", 
"0p40/ref0p4_90min_v6_f20.txt", 
"0p40/ref0p4_90min_v6_f30.txt", 
"0p40/ref0p4_90min_v6_f40.txt", 
"0p40/ref0p4_90min_v6_f50.txt"]


bandas = [
    (0.5, 1.5), 
    (5, 15), 
    (15, 25),
    (25, 35), 
    (35, 45), 
    (45, 55), 
    # (55, 65)
]

import numpy as np
import matplotlib.pyplot as plt
from scipy.signal import butter, filtfilt
import pandas as pd
import os

# ========= PARÁMETROS =========
FILTER_ORDER = 3
DETREND = True
COMBINE_STRATEGY = "best"   # "average" o "best"
USE_WINDOW = (0.35, 0.60)   # ventana intermedia (fracción)
OUTPUT_EXCEL = "Datos_Histereticos_Procesados.xlsx"

# Geometría de la muestra
d = 0.05   # m (50 mm)
h = 0.10   # m (100 mm)
A = np.pi * (d/2)**2  # m²

# ========= FUNCIONES =========
def infer_fs_from_time(t):
    dt = np.diff(t)
    dt = dt[np.isfinite(dt)]
    return 1.0 / np.mean(dt)

def butter_bandpass(x, lowcut, highcut, fs, order=3):
    nyq = 0.5 * fs
    low = lowcut / nyq
    high = highcut / nyq
    b, a = butter(order, [low, high], btype='band')
    return filtfilt(b, a, x)

def band_clean(x, fs, lowcut, highcut):
    y = x - np.nanmean(x) if DETREND else x
    return butter_bandpass(y, lowcut, highcut, fs, order=FILTER_ORDER)

def align_sign_to_reference(y, ref):
    """Alinea el signo de y para que la correlación con ref sea positiva."""
    c = np.corrcoef(y, ref)[0,1]
    return (y if c >= 0 else -y), abs(c)

def pick_force(f1, f2, strategy="average"):
    if strategy == "best":
        r1 = np.sqrt(np.mean(f1**2))
        r2 = np.sqrt(np.mean(f2**2))
        return f1 if r1 >= r2 else f2
    else:
        return 0.5*(f1 + f2)

# ========= PROCESAR Y GUARDAR =========
plt.figure(figsize=(9,7))
legend_labels = []

# Crear un escritor Excel para todas las hojas
writer = pd.ExcelWriter(OUTPUT_EXCEL, engine='openpyxl')

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
    disp_mm = data[:,1]
    force1_lb = data[:,2]
    force2_lb = data[:,3]

    fs = infer_fs_from_time(t)
    print(f"\n{file}: Fs≈{fs:.2f} Hz | Banda = [{lowcut}, {highcut}] Hz")

    # ---- σ–ε sin filtrar (para alinear signos) ----
    F1 = force1_lb * 4.44822   # N
    F2 = force2_lb * 4.44822   # N
    disp_m = disp_mm / 1000.0  # m
    strain = disp_m / h        # adim
    stress1 = F1 / A           # Pa
    stress2 = F2 / A           # Pa

    # Alinear signos
    strain_aligned, _ = align_sign_to_reference(strain, stress1)
    stress1_aligned, c1 = align_sign_to_reference(stress1, strain_aligned)
    stress2_aligned, c2 = align_sign_to_reference(stress2, strain_aligned)
    stress_combined = pick_force(stress1_aligned, stress2_aligned, strategy=COMBINE_STRATEGY)

    # Filtro
    stress_f = band_clean(stress_combined, fs, lowcut, highcut)
    strain_f = band_clean(strain_aligned,  fs, lowcut, highcut)

    # Ventana intermedia
    n = len(stress_f)
    a, b = USE_WINDOW
    i0, i1 = int(a*n), int(b*n)
    stress_cut = stress_f[i0:i1]
    strain_cut = strain_f[i0:i1]

    # Módulo
    k, b0 = np.polyfit(strain_cut, stress_cut, 1)
    E_aprox_MPa = abs(k) / 1e6
    print(f"  -> corr(ε,σ1)={c1:.3f} corr(ε,σ2)={c2:.3f} [{COMBINE_STRATEGY}]  E≈{E_aprox_MPa:.2f} MPa")

    # Plot
    plt.plot(strain_cut, stress_cut/1e6, linewidth=1.0)
    legend_labels.append(f"{os.path.basename(file)} (E={E_aprox_MPa:.1f} MPa)")

    # Guardar hoja Excel
    df = pd.DataFrame({
        "Strain": strain_cut,
        "Stress(Pa)": stress_cut,
        "Stress(MPa)": stress_cut / 1e6
    })
    sheet_name = os.path.splitext(os.path.basename(file))[0][:31]  # máx 31 caracteres
    df.to_excel(writer, sheet_name=sheet_name, index=False)

# Cerrar y guardar Excel
writer.close()
print(f"\n✅ Archivo Excel único guardado: {OUTPUT_EXCEL}")

# ---- Plot final ----
plt.xlabel("Deformación unitaria ε [-]")
plt.ylabel("Esfuerzo σ [MPa]")
plt.title("Ciclos histéréticos (ventana intermedia)")
plt.legend(legend_labels, fontsize=8)
plt.grid(True, alpha=0.4)
plt.tight_layout()
plt.show()
