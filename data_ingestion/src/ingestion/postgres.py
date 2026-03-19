import psycopg2
from psycopg2.extras import Json
from config import POSTGRES_CONFIG


def get_connection():
    return psycopg2.connect(**POSTGRES_CONFIG)


def init_db():
    conn = get_connection()
    cur = conn.cursor()

    with open("sql/bronze/raw_matches.sql", "r") as f:
        cur.execute(f.read())

    conn.commit()
    cur.close()
    conn.close()


def insert_match(
    match_id: str,
    season: int,
    source_file: str,
    file_hash: str,
    payload: dict
):
    conn = get_connection()
    cur = conn.cursor()

    query = """
    INSERT INTO bronze_raw.raw_matches_json
    (match_id, season, source_file, file_hash, raw_payload)
    VALUES (%s, %s, %s, %s, %s)
    ON CONFLICT (match_id) DO NOTHING;
    """

    cur.execute(query, (
        match_id,
        season,
        source_file,
        file_hash,
        Json(payload)
    ))

    conn.commit()
    cur.close()
    conn.close()
