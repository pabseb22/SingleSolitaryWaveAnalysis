import pandas as pd
import joblib
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score
from sklearn.preprocessing import LabelEncoder
import numpy as np

# === 1. Cargar modelo entrenado
model = joblib.load("ssw_model.pkl")
print("Modelo cargado exitosamente.\n")

# === 2. Cargar dataset de prueba
df = pd.read_csv("ml_training_data_complete.csv", sep=";")  # Ajusta sep si tu CSV es tabulado

# Codificar Soil si es categórico
df["Soil"] = LabelEncoder().fit_transform(df["Soil"])

# Separar features y targets
X = df[["Soil", "Energy", "TOF", "F1", "W_Opt", "Dry_Opt"]]
y = df[["Dry", "W"]]

# === 3. Predecir
y_pred = model.predict(X)

# === 4. Evaluación de precisión
mae_dry = mean_absolute_error(y["Dry"], y_pred[:,0])
mae_w = mean_absolute_error(y["W"], y_pred[:,1])

rmse_dry = np.sqrt(mean_squared_error(y["Dry"], y_pred[:,0]))
rmse_w = np.sqrt(mean_squared_error(y["W"], y_pred[:,1]))

r2_dry = r2_score(y["Dry"], y_pred[:,0])
r2_w = r2_score(y["W"], y_pred[:,1])

print("=== Métricas de Evaluación del Modelo ===")
print(f"MAE Dry: {mae_dry:.4f} g/cm³")
print(f"MAE W: {mae_w:.4f} (fracción de humedad)")
print(f"RMSE Dry: {rmse_dry:.4f} g/cm³")
print(f"RMSE W: {rmse_w:.4f} (fracción de humedad)")
print(f"R² Dry: {r2_dry:.4f}")
print(f"R² W: {r2_w:.4f}\n")

# === 5. Mostrar predicciones vs valores reales de los primeros 5 registros
print("Primeros 5 registros - Real vs Predicción:")
for i in range(5):
    print(f"Dry: real={y['Dry'].iloc[i]:.3f}, pred={y_pred[i,0]:.3f} | "
          f"W: real={y['W'].iloc[i]:.3f}, pred={y_pred[i,1]:.3f}")

# === 6. Ejemplo de predicción para un nuevo dato
new_sample = pd.DataFrame([[0, 2, 0.0018, 2.5, 0.094, 2.065]],
                          columns=["Soil", "Energy", "TOF", "F1", "W_Opt", "Dry_Opt"])
pred_new = model.predict(new_sample)
print(f"\nPredicción para nuevo dato: Dry={pred_new[0,0]:.3f}, W={pred_new[0,1]:.3f}")
