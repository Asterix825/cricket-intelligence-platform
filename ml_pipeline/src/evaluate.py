from sklearn.metrics import accuracy_score, roc_auc_score, classification_report, brier_score_loss, log_loss

def evaluate_model(model, X_test, y_test):
    # Get both hard predictions (0/1) and soft probabilities (0.0 to 1.0)
    preds = model.predict(X_test)
    probs = model.predict_proba(X_test)[:, 1]

    acc = accuracy_score(y_test, preds)
    roc = roc_auc_score(y_test, probs)
    brier = brier_score_loss(y_test, probs)
    ll = log_loss(y_test, probs)

    print("\n" + "="*40)
    print("Model Evaluation Report")
    print("="*40)
    
    # Standard Classification Metrics
    print(f"Accuracy:    {acc:.4f}")
    print(f"ROC-AUC:     {roc:.4f}")
    
    # Probability Calibration Metrics (Crucial for the Live Win model)
    print(f"Brier Score: {brier:.4f} (Closer to 0 is better)")
    print(f"Log Loss:    {ll:.4f}")

    print("\nClassification Report:")
    print(classification_report(y_test, preds))

    # Return as a dictionary in case you want to log these to MLflow or Weights & Biases later
    return {
        "accuracy": acc, 
        "roc_auc": roc, 
        "brier_score": brier, 
        "log_loss": ll
    }