import pandas as pd
import joblib

# === 1. Cargar el modelo entrenado
model = joblib.load("ssw_model.pkl")

# === 2. Preparar un nuevo dato (ejemplo)
new_data = pd.DataFrame([[0, 1, 0.0020, 2.6, 0.112, 1.965]],
                        columns=["Soil", "Energy", "TOF", "F1", "W_Opt", "Dry_Opt"])

# === 3. Usar el modelo
prediction = model.predict(new_data)
print("Predicción:", prediction)
