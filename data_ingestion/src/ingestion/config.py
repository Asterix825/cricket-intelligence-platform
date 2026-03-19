import os

# base path
BASE_DIR = os.path.dirname(os.path.dirname(os.path.dirname(__file__)))

DATA_LAKE_PATH = os.path.join(BASE_DIR, "data", "lake", "bronze", "cricsheet", "ipl")

# input zip path(manual download)
ZIP_FILE_PATH = os.path.join(BASE_DIR, "data", "raw", "ipl_json.zip")

# Postgres config
POSTGRES_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "dbname": "cricket_dw",
    "user": "postgres",
    "password": "post2508"
}