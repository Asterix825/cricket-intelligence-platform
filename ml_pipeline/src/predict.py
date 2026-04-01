import joblib
import pandas as pd
import yaml

class CricketModelPredictor:
    def __init__(self, config_path):
        """
        Initializes the predictor by loading the config and model into memory.
        In FastAPI, you instantiate this ONCE during startup.
        """
        with open(config_path, "r") as f:
            self.config = yaml.safe_load(f)

        model_path = self.config["paths"]["model_save_path"]
        self.model = joblib.load(model_path)
        self.features = self.config["data"]["features"]
        
        print(f"Model loaded into memory from {model_path}")

    def predict(self, feature_dict):
        """
        Takes a dictionary of features and returns the prediction.
        """
        try:
            # The config ensures we enforce the exact feature order the model expects
            df = pd.DataFrame([feature_dict])[self.features]
        except KeyError as e:
            raise ValueError(f"Missing required feature: {e}")

        probability = self.model.predict_proba(df)[0][1]
        prediction = self.model.predict(df)[0]

        return {
            "win_prediction": int(prediction),
            "win_probability": float(probability)
        }

# --- Standalone helper for testing in the terminal ---
def test_prediction(config_path, sample_data):
    predictor = CricketModelPredictor(config_path)
    result = predictor.predict(sample_data)
    print(f"Prediction Result: {result}")
    return result