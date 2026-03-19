from xgboost import XGBClassifier
import joblib


def split_and_train(df, config):

    split_date = config["data"]["train_test_split_date"]
    features = config["data"]["features"]
    target = config["data"]["target_col"]

    train_df = df[df["date_key"] < split_date]
    test_df = df[df["date_key"] >= split_date]

    X_train = train_df[features]
    y_train = train_df[target]

    X_test = test_df[features]
    y_test = test_df[target]

    print(f"Training rows: {len(X_train)}")
    print(f"Testing rows: {len(X_test)}")

    model = XGBClassifier(**config["model"]["params"])

    model.fit(X_train, y_train)

    joblib.dump(model, config["paths"]["model_save_path"])

    print("Model saved.")

    return model, X_test, y_test