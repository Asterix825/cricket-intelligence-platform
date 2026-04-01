import argparse
from src.data_loader import load_config, fetch_data
from src.train import split_and_train
from src.evaluate import evaluate_model

def main():
    # 1. Parse the YAML file passed via command line
    parser = argparse.ArgumentParser(description="Cricket Intelligence Platform ML Orchestrator")
    parser.add_argument(
        "--config", 
        type=str, 
        required=True, 
        help="Path to the model configuration YAML file"
    )
    args = parser.parse_args()

    print(f"Starting ML Pipeline using config: {args.config}")
    
    # 2. Pass the dynamic path to your loader
    config = load_config(args.config)

    df = fetch_data(config)
    model, X_test, y_test = split_and_train(df, config)
    evaluate_model(model, X_test, y_test)

    print("Pipeline Complete.")

if __name__ == "__main__":
    main()
