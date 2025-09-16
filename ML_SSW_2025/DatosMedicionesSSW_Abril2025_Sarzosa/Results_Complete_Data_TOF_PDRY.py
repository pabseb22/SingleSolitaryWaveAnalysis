import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.cm as cm
import matplotlib.colors as colors

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
    'saturacion': [
    32.12,
    45.93,
    68.05,
    88.59,
    84.00,

    42.16,
    70.35,
    84.48,
    85.64,

    65.45,
    83.61,
    90.55,
    84.37

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
    'saturacion': [
            72.15,
            89.01,
            93.24,
            45.41,

            54.01,
            80.04,
            93.54,
            35.92,
            84.75,

            48.56,
            87.70,
            97.82,
            97.16

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
        'saturacion': [
            74.97,
            90.47,
            27.93,
            77.48,
            34.51,

            24.15,
            57.02,
            89.27,
            96.93,

            29.96,
            24.22,
            67.19,
            77.76,
            65.41
    ],
    'tof': [
        0.002054728, 0.003570382, 0.001941444, 0.002480517, 0.001773472,
        0.000898455, 0.001027364, 0.001937538, 0.003320377,
        0.001234399, 0.002324264, 0.003097717, 0.003382879, 0.001084006
    ]
}

data_arena = {
    'rho_dry': [
        1.894739705, 1.934844437, 1.966078143, 1.957691618, 1.89600099,
        2.016690673, 2.046016873, 2.054876802, 2.056145868, 1.936681976,
        2.078826071, 2.123278594, 2.128902, 2.046925317
    ],
    'humedad': [
        7.63, 9.60, 11.95, 13.16, 14.39,
        5.71, 6.95, 9.40, 10.99, 15.47,
        4.54, 7.81, 9.91, 12.47
    ],
    'saturacion': [
37.44,
54.51,
75.83,
83.65,
82.53,

31.34,
44.40,
67.67,
82.53,
96.89,

24.51,
62.02,
85.64,
94.19

    ],
    'tof': [
        0.002531299, 0.001918006, 0.002132854, 0.002632864, 0.002054728,
        0.001609406, 0.001351589, 0.001312526, 0.002289107, 0.002722709,
        0.002191449, 0.001546905, 0.001507842, 0.002261763
    ]
}



# Crear DataFrames
df_limo = pd.DataFrame(data_limo)
df_caolin = pd.DataFrame(data_caolin)
df_base = pd.DataFrame(data_base)
df_arena = pd.DataFrame(data_arena)



# Configurar fuente global
plt.rcParams['font.family'] = 'Times New Roman'

# Crear figura
fig, ax = plt.subplots(figsize=(10, 6))

scatter_limo = ax.scatter(df_limo['rho_dry'], df_limo['tof'], c=df_limo['saturacion'], cmap='viridis_r', s=100, edgecolor='k',  label='Limo')
scatter_caolin = ax.scatter(df_caolin['rho_dry'], df_caolin['tof'], c=df_caolin['saturacion'], cmap='viridis_r', s=100, edgecolor='k', marker='s', label='Caolín')
scatter_base = ax.scatter(df_base['rho_dry'], df_base['tof'], c=df_base['saturacion'], cmap='viridis_r', s=100, edgecolor='k', marker='v', label='Base')
scatter_arena = ax.scatter(df_arena['rho_dry'], df_arena['tof'], c=df_arena['saturacion'], cmap='viridis_r', s=100, edgecolor='k', marker='D', label='Arena')


# Barra de color
cbar = plt.colorbar(scatter_limo)
cbar.set_label('Saturacion (%)', fontsize=12, fontweight='bold')

# Etiquetas y título
ax.set_xlabel('Densidad Seca (g/cm³)', fontsize=14, fontweight='bold')
ax.set_ylabel('TOF Promedio (s)', fontsize=14, fontweight='bold')
ax.set_title('TOF vs Densidad Seca', fontsize=16, fontweight='bold')

# Fuente de ticks también en Times y bold
ax.tick_params(labelsize=12)
for label in (ax.get_xticklabels() + ax.get_yticklabels()):
    label.set_fontname('Times New Roman')
    label.set_fontweight('bold')

# Leyenda
ax.legend(fontsize=12, loc='upper right')

# Grid y ajustes
plt.tight_layout()

# Guardar con alta resolución (600 dpi)
plt.savefig("Total_TOF_vs_DensidadSeca.png", dpi=600)

# Mostrar en pantalla
plt.show()
