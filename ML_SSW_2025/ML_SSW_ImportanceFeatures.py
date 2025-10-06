import pandas as pd
import joblib

# Load trained model
model = joblib.load("ssw_model.pkl")

# If you know the feature names
feature_names = ["Soil", "Energy", "TOF", "F1", "W_Opt", "Dry_Opt"]  # replace with your real features

for i, est in enumerate(model.estimators_):
    importances = est.feature_importances_
    importance_df = pd.DataFrame({
        "Feature": feature_names,
        "Importance": importances
    }).sort_values(by="Importance", ascending=False)

    print(f"\n=== Output {i} ===")
    print(importance_df)

