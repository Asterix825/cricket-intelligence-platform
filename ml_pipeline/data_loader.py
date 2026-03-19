import pandas as pd
from sqlalchemy import create_engine
import yaml


def load_config():
    with open("./config.yaml", "r") as f:
        return yaml.safe_load(f)


def fetch_data(config):
    try:
        engine = create_engine(config["database"]["connection_string"])

        query = """
        SELECT
            t.date_key,
            t.team_total_runs,
            t.team_run_rate,
            t.total_wickets_lost,
            CASE WHEN dm.winner = dt.team_name THEN 1 ELSE 0 END AS target
        FROM feature_store.team_match_features t
        JOIN gold_analytics.dim_match dm
            ON t.match_key = dm.match_key
        JOIN gold_analytics.dim_team dt
            ON t.team_key = dt.team_key
        ORDER BY t.date_key ASC
        """

        df = pd.read_sql(query, engine)

        features = config["data"]["features"]

        df[features] = df[features].fillna(0)
        # print(f"res of fecth_data: {df}")
        return df
    
    except Exception as e:
        print(f"error in fecthdata: {e}")