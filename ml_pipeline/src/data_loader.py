import pandas as pd
from sqlalchemy import create_engine
import yaml

def load_config(config_path):
    """Dynamically load the yaml file passed from main.py"""
    with open(config_path, "r") as f:
        return yaml.safe_load(f)

def fetch_data(config):
    try:
        engine = create_engine(config["database"]["connection_string"])

        # Fetch the query defined in the YAML file
        query = config["data"]["sql_query"]
        df = pd.read_sql(query, engine)

        features = config["data"]["features"]

        # Ensure we only fillna on the columns we are actually using
        df[features] = df[features].fillna(0)
        
        return df
    
    except Exception as e:
        print(f"Error in fetch_data: {e}")
        # Always raise the exception in pipelines so orchestrators (like Airflow) know it failed
        raise