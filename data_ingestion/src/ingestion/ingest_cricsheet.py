import zipfile
import json
import os

from config import DATA_LAKE_PATH, ZIP_FILE_PATH
from filesystem import compute_sha256, get_season_from_json, write_to_lake
from postgres import init_db, insert_match


def process_zip():
    with zipfile.ZipFile(ZIP_FILE_PATH, 'r') as zip_ref:
        for file_name in zip_ref.namelist():

            if not file_name.endswith(".json"):
                continue

            content = zip_ref.read(file_name)
            file_hash = compute_sha256(content)

            json_data = json.loads(content)

            # Extract metadata
            match_id = file_name.replace(".json", "")
            season = get_season_from_json(json_data)

            # Write to data lake
            write_to_lake(
                DATA_LAKE_PATH,
                season,
                file_name,
                content
            )

            # Insert into Postgres
            insert_match(
                match_id,
                season,
                file_name,
                file_hash,
                json_data
            )

            print(f"Processed: {file_name}")


if __name__ == "__main__":
    print("Initializing DB...")
    init_db()

    print("Starting ingestion...")
    process_zip()

    print("Done")
