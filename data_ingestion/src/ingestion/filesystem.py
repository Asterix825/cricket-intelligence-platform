import os
import json
import hashlib

def ensure_directory(path: str):
    os.makedirs(path, exist_ok=True)


def compute_sha256(content: bytes) -> str:
    return hashlib.sha256(content).hexdigest()


def get_season_from_json(json_data: dict) -> int:

    season = json_data["info"]["season"]

    if isinstance(season, int):
        return season

    if isinstance(season, str):
        if "/" in season:
            season = season.split("/")[0]
        return int(season)

    # fallback
    raise ValueError(f"Unexpected season format: {season}")


def write_to_lake(base_path: str, season: int, filename: str, content: bytes):
    season_path = os.path.join(base_path, f"season={season}")
    ensure_directory(season_path)

    file_path = os.path.join(season_path, filename)

    # Idempotent write → do not overwrite
    if not os.path.exists(file_path):
        with open(file_path, "wb") as f:
            f.write(content)

    return file_path
