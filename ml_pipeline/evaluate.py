from sklearn.metrics import accuracy_score, roc_auc_score, classification_report


def evaluate_model(model, X_test, y_test):

    preds = model.predict(X_test)
    probs = model.predict_proba(X_test)[:, 1]

    acc = accuracy_score(y_test, preds)
    roc = roc_auc_score(y_test, probs)

    print("\nModel Evaluation")
    print("--------------------")
    print(f"Accuracy: {acc:.4f}")
    print(f"ROC-AUC: {roc:.4f}")

    print("\nClassification Report:")
    print(classification_report(y_test, preds))

    return acc, roc