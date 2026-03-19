import joblib
import pandas as pd
import yaml


def predict_match_outcome(feature_dict):

    with open("./config.yaml") as f:
        config = yaml.safe_load(f)

    model = joblib.load(config["paths"]["model_save_path"])

    features = config["data"]["features"]

    df = pd.DataFrame([feature_dict])[features]

    probability = model.predict_proba(df)[0][1]

    prediction = model.predict(df)[0]

    return {
        "win_prediction": int(prediction),
        "win_probability": float(probability)
    }