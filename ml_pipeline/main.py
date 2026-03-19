from data_loader import load_config, fetch_data
from train import split_and_train
from evaluate import evaluate_model


def main():

    print("Starting ML Pipeline")

    config = load_config()

    df = fetch_data(config)

    model, X_test, y_test = split_and_train(df, config)

    evaluate_model(model, X_test, y_test)

    print("Pipeline Complete")


if __name__ == "__main__":
    main()