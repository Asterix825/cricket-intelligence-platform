from xgboost import XGBClassifier
import joblib
import os

def split_and_train(df, config):
    split_date = config["data"]["train_test_split_date"]
    temporal_col = config["data"]["temporal_col"]
    features = config["data"]["features"]
    target = config["data"]["target_col"]

    # Dynamically split based on whatever column the YAML specified
    train_df = df[df[temporal_col] < split_date]
    test_df = df[df[temporal_col] >= split_date]

    X_train = train_df[features]
    y_train = train_df[target]

    X_test = test_df[features]
    y_test = test_df[target]

    print(f"Training rows: {len(X_train)}")
    print(f"Testing rows: {len(X_test)}")

    model = XGBClassifier(**config["model"]["params"])
    model.fit(X_train, y_train)

    # Safely save the model to the configured path
    save_path = config["paths"]["model_save_path"]
    os.makedirs(os.path.dirname(save_path), exist_ok=True)
    joblib.dump(model, save_path)

    print(f"Model successfully saved to {save_path}")

    return model, X_test, y_test
