import pandas as pd
import matplotlib.pyplot as plt


# Datos
data_limo = {
    'rho_dry': [
        1.371360302, 1.453772708, 1.51616259, 1.52644833, 1.372311344,
        1.562097126, 1.652884988, 1.664219087, 1.51631111,
        1.725712965, 1.759103654, 1.709105744, 1.555828905
    ],
    'humedad': [
        11.30, 14.26, 19.20, 24.61, 29.51,
        11.08, 16.01, 18.88, 24.16,
        13.23, 15.98, 18.81, 22.39
    ],
    'tof': [
        0.001847692, 0.001731805, 0.001660189, 0.002656302, 0.00309381,
        0.001621125, 0.001582062, 0.001742222, 0.00256255,
        0.001207055, 0.001441434, 0.002027383, 0.002355515
    ]
}

data_caolin = {
    'rho_dry': [
        1.660557081, 1.661585943, 1.506863699, 1.574778323,
        1.741579267, 1.789430617, 1.806194734, 1.667328134, 1.5456713,
        1.774361562, 1.820298853, 1.763673809, 1.64282503
    ],
    'humedad': [
        16.22, 19.98, 26.69, 11.70,
        10.63, 14.52, 16.49, 7.99, 22.85,
        9.04, 15.09, 18.55, 22.48
    ],
    'tof': [
        0.001527374, 0.002890681, 0.003125061, 0.001601594,
        0.001269556, 0.001254907, 0.001464872, 0.001298853, 0.001777378,
        0.001207055, 0.001101584, 0.001398465, 0.002300826
    ]
}

data_base = {
    'rho_dry': [
        2.059363599, 1.962142487, 1.953032579, 2.054654697, 1.981508894,
        2.098604072, 2.150557895, 2.149155695, 2.082624829,
        2.114746798, 2.07451988, 2.002669063, 2.115764808, 2.203277372
    ],
    'humedad': [
        10.61, 14.47, 6.26, 10.97, 6.89,
        4.89, 7.50, 10.35, 12.47,
        5.36, 5.03, 10.70, 9.91, 7.50
    ],
    'tof': [
        0.002054728, 0.003570382, 0.001941444, 0.002480517, 0.001773472,
        0.000898455, 0.001027364, 0.001937538, 0.003320377,
        0.001234399, 0.002324264, 0.003097717, 0.003382879, 0.001084006
    ]
}


# Crear DataFrame
df = pd.DataFrame(data_base)

# Configurar fuente global
plt.rcParams['font.family'] = 'Times New Roman'

# Crear figura
fig, ax = plt.subplots(figsize=(10, 6))

# Scatter plot
scatter = ax.scatter(df['rho_dry'], df['tof'], c=df['humedad'], cmap='viridis_r', s=100, edgecolor='k')

# Barra de color
cbar = plt.colorbar(scatter)
cbar.set_label('Humedad (%)', fontsize=12, fontweight='bold')

# Etiquetas y título
ax.set_xlabel('Densidad Seca (g/cm³)', fontsize=14, fontweight='bold')
ax.set_ylabel('TOF Promedio (s)', fontsize=14, fontweight='bold')
ax.set_title('Base: TOF vs Densidad Seca', fontsize=16, fontweight='bold')

# Fuente de ticks también en Times y bold
ax.tick_params(labelsize=12)
for label in (ax.get_xticklabels() + ax.get_yticklabels()):
    label.set_fontname('Times New Roman')
    label.set_fontweight('bold')

# Grid y ajustes
plt.tight_layout()

# Guardar con alta resolución (600 dpi)
plt.savefig("Base_TOF_vs_DensidadSeca.png", dpi=600)

# Mostrar en pantalla
plt.show()
