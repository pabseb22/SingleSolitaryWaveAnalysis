import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder
from sklearn.ensemble import RandomForestRegressor
from sklearn.multioutput import MultiOutputRegressor
from sklearn.metrics import mean_absolute_error, r2_score
import joblib 

# === 1. Cargar datos
df = pd.read_csv("ml_training_data_complete.csv",  sep=";")

# === 2. Codificar Soil como número
df["Soil"] = LabelEncoder().fit_transform(df["Soil"])

# === 3. Separar features y targets
X = df[["Soil", "Energy", "TOF", "F1", "W_Opt", "Dry_Opt"]]
y = df[["Dry", "W"]]

# === 4. Dividir train/test
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=42)

# === 5. Modelo: Random Forest multisalida
model = MultiOutputRegressor(RandomForestRegressor(n_estimators=200, random_state=42))
model.fit(X_train, y_train)

# === 6. Evaluación
y_pred = model.predict(X_test)
print("MAE Dry:", mean_absolute_error(y_test["Dry"], y_pred[:,0]))
print("MAE W:", mean_absolute_error(y_test["W"], y_pred[:,1]))
print("R2 Dry:", r2_score(y_test["Dry"], y_pred[:,0]))
print("R2 W:", r2_score(y_test["W"], y_pred[:,1]))


# === 7. Guardar modelo entrenado
joblib.dump(model, "ssw_model.pkl")
print("Modelo guardado en ssw_model.pkl")

# TODO: Cambiar energia a joules. Graficas de relacion de features y relacion entre variables.
# Entre el feature y el target.

# 2. Revisar que es random forest, por que funciona, que parametros recibe y que otras alternativas.

# 3. Revisar papers de ejemplo que usen ML para ver como muestran resultados.

# 4. Agregar Base.
